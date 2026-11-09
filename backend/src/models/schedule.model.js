const pool = require('../db/pool');

const BASE = `SELECT s.id, s.area_id, s.day_of_week, s.start_time, s.end_time,
    s.waste_types, s.is_active, s.created_at,
    a.name AS area_name, b.name AS barangay_name
  FROM collection_schedules s
  JOIN areas a ON a.id = s.area_id
  JOIN barangays b ON b.id = a.barangay_id`;

exports.list = async ({ areaId = null, activeOnly = false }) => {
  const r = await pool.query(
    `${BASE}
     WHERE ($1::int IS NULL OR s.area_id = $1)
       AND ($2::boolean = false OR s.is_active)
     ORDER BY s.day_of_week, s.start_time, a.name`,
    [areaId, activeOnly]);
  return r.rows;
};

exports.createMany = async (areaIds, d) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const rows = [];
    for (const areaId of areaIds) {
      const r = await client.query(
        `INSERT INTO collection_schedules
           (area_id, day_of_week, start_time, end_time, waste_types, is_active)
         VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [areaId, d.day_of_week, d.start_time, d.end_time, d.waste_types, d.is_active ?? true]);
      rows.push(r.rows[0]);
    }
    await client.query('COMMIT');
    return rows;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

exports.update = async (id, d) => {
  const r = await pool.query(
    `UPDATE collection_schedules
     SET area_id = $1, day_of_week = $2, start_time = $3, end_time = $4,
         waste_types = $5, is_active = $6
     WHERE id = $7 RETURNING *`,
    [d.area_id, d.day_of_week, d.start_time, d.end_time, d.waste_types, d.is_active ?? true, id]);
  return r.rows[0];
};

exports.remove = async (id) => {
  const r = await pool.query('DELETE FROM collection_schedules WHERE id = $1', [id]);
  return r.rowCount > 0;
};