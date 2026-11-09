const { test } = require('node:test');
const assert = require('node:assert/strict');
const { describeDatabaseError } = require('../src/db/errors');

test('empty aggregate errors explain the refused database connection', () => {
  const error = new AggregateError([{ code: 'ECONNREFUSED' }, { code: 'ECONNREFUSED' }]);
  const message = describeDatabaseError(error);
  assert.match(message, /PostgreSQL refused the connection/);
  assert.equal(message.match(/PostgreSQL refused/g).length, 1);
});

test('unknown driver errors do not expose connection credentials', () => {
  assert.equal(describeDatabaseError(new Error('postgresql://secret:password@host/db')),
    'Database operation failed. Check DATABASE_URL, PostgreSQL availability, and network access.');
  assert.match(describeDatabaseError({ code: '42P01' }), /tables are missing/);
  assert.match(describeDatabaseError({ code: '28P01' }), /username or password/);
});
