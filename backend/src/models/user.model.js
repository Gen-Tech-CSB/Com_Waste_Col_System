const pool = require('../db/pool');

exports.findByEmail = async (email) => {
  const r = await pool.query('SELECT * FROM users WHERE email = $1', [email.toLowerCase()]);
  return r.rows[0];
};

exports.findById = async (id) => {
  const r = await pool.query(
    'SELECT id, full_name, email, role, area_id, phone FROM users WHERE id = $1', [id]);
  return r.rows[0];
};

exports.create = async ({ full_name, email, password_hash, area_id, phone }) => {
  const r = await pool.query(
    `INSERT INTO users (full_name, email, password_hash, area_id, phone)
     VALUES ($1, $2, $3, $4, $5)
     RETURNING id, full_name, email, role, area_id`,
    [full_name, email.toLowerCase(), password_hash, area_id ?? null, phone ?? null]);
  return r.rows[0];
};