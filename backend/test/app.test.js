const { test } = require('node:test');
const assert = require('node:assert/strict');
const app = require('../src/app');
const pool = require('../src/db/pool');

test('API rejects unauthenticated requests and invalid registration', async () => {
  const server = app.listen(0, '127.0.0.1');
  await new Promise(resolve => server.once('listening', resolve));
  const origin = `http://127.0.0.1:${server.address().port}`;
  try {
    const protectedResponse = await fetch(`${origin}/api/reports/mine`);
    assert.equal(protectedResponse.status, 401);
    assert.equal((await protectedResponse.json()).success, false);
    const invalid = await fetch(`${origin}/api/auth/register`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'invalid', password: 'short' }),
    });
    assert.equal(invalid.status, 400);
    assert.equal((await invalid.json()).success, false);
  } finally {
    await new Promise(resolve => server.close(resolve));
    await pool.end();
  }
});
