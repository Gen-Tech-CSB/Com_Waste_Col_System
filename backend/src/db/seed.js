require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./pool');

const data = {
  'Barangay Uno': ['Purok 1', 'Purok 2', 'Purok 3', 'Purok 4'],
  'Barangay Dos': ['Purok 1', 'Purok 2', 'Purok 3', 'Purok 4'],
};

// 0 = Sunday, 1 = Monday, ... 6 = Saturday
const plan = {
  'Barangay Uno': [1, 4],
  'Barangay Dos': [2, 5],
};

(async () => {
  try {
    for (const [name, areas] of Object.entries(data)) {
      const b = await pool.query(
        `INSERT INTO barangays (name) VALUES ($1)
         ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
         RETURNING id`, [name]);
      for (const a of areas) {
        await pool.query(
          `INSERT INTO areas (barangay_id, name) VALUES ($1, $2)
           ON CONFLICT (barangay_id, name) DO NOTHING`, [b.rows[0].id, a]);
      }
    }

    const area = (await pool.query('SELECT id FROM areas ORDER BY id LIMIT 1')).rows[0].id;
    const hash = await bcrypt.hash('Password123', 10);
    const users = [
      ['Admin User', 'admin@waste.test', 'admin'],
      ['Collector User', 'collector@waste.test', 'collector'],
      ['Resident User', 'resident@waste.test', 'resident'],
    ];
    for (const [fullName, email, role] of users) {
      await pool.query(
        `INSERT INTO users (full_name, email, password_hash, role, area_id)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (email) DO NOTHING`, [fullName, email, hash, role, area]);
    }

    const count = await pool.query('SELECT COUNT(*)::int AS n FROM collection_schedules');
    if (count.rows[0].n === 0) {
      for (const [barangay, days] of Object.entries(plan)) {
        const areas = await pool.query(
          `SELECT a.id FROM areas a JOIN barangays b ON b.id = a.barangay_id
           WHERE b.name = $1 ORDER BY a.id`, [barangay]);
        for (const day of days) {
          for (const row of areas.rows) {
            await pool.query(
              `INSERT INTO collection_schedules (area_id, day_of_week, start_time, end_time)
               VALUES ($1, $2, '06:00', '09:00')`, [row.id, day]);
          }
        }
      }
    }
    console.log('seed done');
  } catch (e) {
    console.error('seed failed:', e.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();