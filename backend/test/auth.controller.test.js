const { test } = require('node:test');
const assert = require('node:assert/strict');
const bcrypt = require('bcrypt');
const pool = require('../src/db/pool');
const app = require('../src/app');

test('auth API validates, normalizes, hashes and inserts accounts before reporting success', async (t) => {
  process.env.JWT_SECRET = 'unit-test-only-secret';
  process.env.JWT_EXPIRES_IN = '1d';
  let stored;
  t.mock.method(pool, 'query', async (sql, values) => {
    if (sql.includes('INSERT INTO users')) {
      if (stored) throw Object.assign(new Error('duplicate'), { code: '23505' });
      assert.equal(values[0], 'New Resident');
      assert.equal(values[1], 'new@example.test');
      assert.equal(await bcrypt.compare('password123', values[2]), true);
      assert.match(sql, /RETURNING id, full_name, email, role, area_id/);
      stored = { id: 9, full_name: values[0], email: values[1], password_hash: values[2], area_id: null, role: 'resident' };
      const { password_hash, ...publicUser } = stored;
      return { rows: [publicUser] };
    }
    if (sql.includes('SELECT * FROM users WHERE email')) return { rows: stored ? [stored] : [] };
    throw new Error('Unexpected database query');
  });
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const origin = `http://127.0.0.1:${server.address().port}/api`;
  const post = (path, body) => fetch(origin + path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  try {
    const payload = { full_name: ' New Resident ', email: ' NEW@example.test ', password: 'password123', role: 'admin' };
    const bad = await post('/auth/register', { ...payload, password: 'short' });
    assert.equal(bad.status, 400);
    assert.equal(stored, undefined);
    const created = await post('/auth/register', payload);
    assert.equal(created.status, 201);
    const data = (await created.json()).data;
    assert.equal(data.role, 'resident');
    assert.equal(data.password_hash, undefined);
    assert.equal((await post('/auth/register', payload)).status, 409);
    const login = await post('/auth/login', { email: payload.email, password: payload.password });
    assert.equal(login.status, 200);
    const session = (await login.json()).data;
    assert.equal(session.user.id, 9);
    assert.equal(session.user.password_hash, undefined);
    assert.equal(typeof session.token, 'string');
    assert.equal((await post('/auth/login', { email: payload.email, password: 'wrong' })).status, 401);
    assert.equal((await post('/auth/login', { email: {}, password: [] })).status, 400);
    const malformed = await fetch(origin + '/auth/register', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: '{' });
    assert.equal(malformed.status, 400);
    assert.equal((await malformed.json()).message, 'Invalid JSON request');
  } finally {
    await new Promise(resolve => server.close(resolve));
    await pool.end();
  }
});
