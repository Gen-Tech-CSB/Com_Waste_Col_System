require('dotenv').config();
const fs = require('fs');
const path = require('path');
const pool = require('./pool');

(async () => {
  await pool.query(`CREATE TABLE IF NOT EXISTS schema_migrations (
    filename TEXT PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT now()
  )`);

  const dir = path.join(__dirname, 'migrations');
  const files = fs.readdirSync(dir).filter(f => f.endsWith('.sql')).sort();

  for (const f of files) {
    const done = await pool.query('SELECT 1 FROM schema_migrations WHERE filename = $1', [f]);
    if (done.rowCount) { console.log('skip', f); continue; }

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(fs.readFileSync(path.join(dir, f), 'utf8'));
      await client.query('INSERT INTO schema_migrations (filename) VALUES ($1)', [f]);
      await client.query('COMMIT');
      console.log('applied', f);
    } catch (e) {
      await client.query('ROLLBACK');
      console.error('failed', f, '-', e.message);
      process.exitCode = 1;
      break;
    } finally {
      client.release();
    }
  }
  await pool.end();
})();