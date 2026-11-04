const pool = require('../db/pool');

exports.listAll = async () => {
  const r = await pool.query(
    `SELECT a.id, a.name AS area_name, b.id AS barangay_id, b.name AS barangay_name
     FROM areas a JOIN barangays b ON b.id = a.barangay_id
     ORDER BY b.name, a.name`);
  return r.rows;
};