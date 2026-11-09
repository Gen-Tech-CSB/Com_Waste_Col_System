const pool = require('./pool');
const { describeDatabaseError } = require('./errors');

(async () => {
  try {
    if (!process.env.DATABASE_URL && !process.env.PGHOST) {
      console.error('Database settings are missing. Set DATABASE_URL in backend/.env.');
      process.exitCode = 1;
      return;
    }
    await pool.query('SELECT 1');
    const result = await pool.query(`SELECT to_regclass('public.users') IS NOT NULL AS users,
      to_regclass('public.barangays') IS NOT NULL AS barangays,
      to_regclass('public.areas') IS NOT NULL AS areas,
      to_regclass('public.collection_schedules') IS NOT NULL AS schedules`);
    if (Object.values(result.rows[0]).some(value => !value)) {
      console.error('Database connected, but required tables are missing. Run npm.cmd run migrate against your development database before seeding.');
      process.exitCode = 1;
    } else {
      console.log('Database connected. Required seed tables are available.');
    }
  } catch (error) {
    console.error('Database check failed:', describeDatabaseError(error));
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();
