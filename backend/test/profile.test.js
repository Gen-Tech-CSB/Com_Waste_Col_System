const { test } = require('node:test');
const assert = require('node:assert/strict');
const jwt = require('jsonwebtoken');
const pool = require('../src/db/pool');
const app = require('../src/app');

test('profile updates are authenticated, limited to editable fields, and scoped to the token user', async (t) => {
  process.env.JWT_SECRET = 'profile-test-secret';
  let updates = 0;
  const stored = { id: 9, full_name: 'Original Resident', email: 'resident@example.com', role: 'resident', phone: '123', area_id: 1 };
  t.mock.method(pool, 'query', async (sql, values) => {
    assert.equal(values[0], 9);
    if (sql.includes('UPDATE users')) {
      updates++;
      assert.match(sql, /WHERE id = \$1/);
      assert.match(sql, /full_name = \$2, phone = \$3, area_id = \$4/);
      assert.deepEqual(values, [9, 'Updated Resident', null, 2]);
      stored.full_name = values[1]; stored.phone = values[2]; stored.area_id = values[3];
    }
    return { rows: [{ ...stored }] };
  });
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const origin = `http://127.0.0.1:${server.address().port}/api/auth/me`;
  const token = jwt.sign({ id: 9, role: 'resident' }, process.env.JWT_SECRET);
  const patch = (body, authenticated = true) => fetch(origin, { method: 'PATCH', headers: { 'Content-Type': 'application/json', ...(authenticated ? { Authorization: `Bearer ${token}` } : {}) }, body: JSON.stringify(body) });
  try {
    assert.equal((await patch({ full_name: 'New Name' }, false)).status, 401);
    for (const body of [{}, { full_name: 'A' }, { phone: 'x'.repeat(21) }, { area_id: -1 }, { role: 'admin' }, { id: 10, full_name: 'Hacker' }, { email: 'changed@example.com' }]) {
      assert.equal((await patch(body)).status, 400);
    }
    assert.equal(updates, 0);
    const saved = await patch({ full_name: ' Updated Resident ', phone: null, area_id: 2 });
    assert.equal(saved.status, 200);
    const user = (await saved.json()).data;
    assert.equal(user.full_name, 'Updated Resident');
    assert.equal(user.role, 'resident');
    assert.equal(user.email, 'resident@example.com');
    assert.equal(user.phone, null);
    assert.equal(user.password_hash, undefined);
    const refreshed = await fetch(origin, { headers: { Authorization: `Bearer ${token}` } });
    assert.deepEqual((await refreshed.json()).data, user);
    assert.equal(updates, 1);
  } finally {
    await new Promise(resolve => server.close(resolve));
    await pool.end();
  }
});
