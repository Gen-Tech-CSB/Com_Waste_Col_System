require('dotenv').config();
const bcrypt = require('bcrypt');
const pool = require('./pool');

// Ilisi ang mga ngalan sa barangay/purok nga gamiton sa inyong demo
const data = {
  'Barangay Uno': ['Purok 1', 'Purok 2', 'Purok 3'],
  'Barangay Dos': ['Purok 1', 'Purok 2'],
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
    console.log('seed done');
  } catch (e) {
    console.error('seed failed:', e.message);
    process.exitCode = 1;
  } finally {
    await pool.end();
  }
})();