const { test } = require('node:test');
const assert = require('node:assert/strict');

// Enable only against the disposable CI database, never a teammate's database.
test('registration persists a resident, hashes passwords, and permits real login', { skip: process.env.RUN_DB_TESTS !== '1' }, async () => {
  process.env.JWT_SECRET ||= 'integration-test-only-secret';
  process.env.JWT_EXPIRES_IN = '1d';
  const app = require('../src/app');
  const pool = require('../src/db/pool');
  const bcrypt = require('bcrypt');
  const email = `registration-${require('node:crypto').randomUUID()}@example.test`;
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const origin = `http://127.0.0.1:${server.address().port}/api`;
  const post = (path, body) => fetch(origin + path, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
  try {
    const invalid = await post('/auth/register', { full_name: ' ', email, password: 'password123' });
    assert.equal(invalid.status, 400);
    const payload = { full_name: ' Registration Test ', email: email.toUpperCase(), password: 'password123', role: 'admin' };
    const created = await post('/auth/register', payload);
    assert.equal(created.status, 201);
    const account = await created.json();
    assert.equal(account.data.role, 'resident');
    assert.equal(account.data.email, email);
    assert.equal(account.data.password_hash, undefined);
    const row = (await pool.query('SELECT * FROM users WHERE email = $1', [email])).rows[0];
    assert.equal(row.full_name, 'Registration Test');
    assert.notEqual(row.password_hash, payload.password);
    assert.equal(await bcrypt.compare(payload.password, row.password_hash), true);
    const duplicate = await post('/auth/register', payload);
    assert.equal(duplicate.status, 409);
    const login = await post('/auth/login', { email: email.toUpperCase(), password: payload.password });
    assert.equal(login.status, 200);
    const session = (await login.json()).data;
    assert.ok(session.token);
    const me = await fetch(origin + '/auth/me', { headers: { Authorization: `Bearer ${session.token}` } });
    assert.equal((await me.json()).data.id, row.id);
    const updated = await fetch(origin + '/auth/me', { method: 'PATCH', headers: {
      Authorization: `Bearer ${session.token}`, 'Content-Type': 'application/json',
    }, body: JSON.stringify({ full_name: 'Updated Registration Test', phone: '09001234567' }) });
    assert.equal(updated.status, 200);
    const savedProfile = (await pool.query('SELECT full_name, phone FROM users WHERE id = $1', [row.id])).rows[0];
    assert.deepEqual(savedProfile, { full_name: 'Updated Registration Test', phone: '09001234567' });
    const forbidden = await fetch(origin + '/reports/summary', { headers: { Authorization: `Bearer ${session.token}` } });
    assert.equal(forbidden.status, 403);
    const adminToken = require('jsonwebtoken').sign({ id: row.id, role: 'admin' }, process.env.JWT_SECRET);
    const summary = await fetch(origin + '/reports/summary', { headers: { Authorization: `Bearer ${adminToken}` } });
    assert.equal(summary.status, 200);
    const counts = (await summary.json()).data;
    assert.equal(typeof counts.total, 'number');
    assert.equal(counts.total, counts.submitted + counts.under_review + counts.in_progress + counts.resolved + counts.rejected);
  } finally {
    await pool.query('DELETE FROM users WHERE email = $1', [email]);
    await new Promise(resolve => server.close(resolve));
    await pool.end();
  }
});
