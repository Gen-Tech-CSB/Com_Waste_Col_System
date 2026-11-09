const pool = require('../db/pool');

const NOW_MNL = "(now() AT TIME ZONE 'Asia/Manila')";

const BASE = `SELECT cr.id, cr.schedule_id, cr.run_date::text AS run_date, cr.status,
    cr.reason, cr.marked_at, mu.full_name AS marked_by_name,
    s.area_id, a.name AS area_name, b.name AS barangay_name,
    s.start_time, s.end_time, s.waste_types
  FROM collection_runs cr
  JOIN collection_schedules s ON s.id = cr.schedule_id
  JOIN areas a ON a.id = s.area_id
  JOIN barangays b ON b.id = a.barangay_id
  LEFT JOIN users mu ON mu.id = cr.marked_by`;

// Maghimo og run para sa tanang active schedule nga mugna karong adlawa
exports.ensureToday = async () => {
  await pool.query(
    `INSERT INTO collection_runs (schedule_id, run_date)
     SELECT s.id, ${NOW_MNL}::date
     FROM collection_schedules s
     WHERE s.is_active AND s.day_of_week = EXTRACT(DOW FROM ${NOW_MNL})::int
     ON CONFLICT (schedule_id, run_date) DO NOTHING`);
};

// Ang pending nga lapas na sa end_time himoong missed
exports.markOverdue = async () => {
  await pool.query(
    `UPDATE collection_runs cr SET status = 'missed'
     FROM collection_schedules s
     WHERE s.id = cr.schedule_id AND cr.status = 'pending'
       AND (cr.run_date + s.end_time) < ${NOW_MNL}`);
};

exports.findById = async (id) => {
  const r = await pool.query(`${BASE} WHERE cr.id = $1`, [id]);
  return r.rows[0];
};

exports.list = async ({ date = null, status = null, areaId = null } = {}) => {
  const r = await pool.query(
    `${BASE}
     WHERE cr.run_date = COALESCE($1::date, ${NOW_MNL}::date)
       AND ($2::run_status IS NULL OR cr.status = $2)
       AND ($3::int IS NULL OR s.area_id = $3)
     ORDER BY b.name, a.name, s.start_time`, [date, status, areaId]);
  return r.rows;
};

exports.listForArea = async (areaId, days = 7) => {
  const r = await pool.query(
    `${BASE}
     WHERE s.area_id = $1
       AND cr.run_date BETWEEN (${NOW_MNL}::date - $2::int) AND ${NOW_MNL}::date
     ORDER BY cr.run_date DESC, s.start_time`, [areaId, days - 1]);
  return r.rows;
};

exports.mark = async (id, status, reason, userId) => {
  const r = await pool.query(
    `UPDATE collection_runs
     SET status = $1, reason = $2, marked_by = $3, marked_at = now()
     WHERE id = $4 AND status IN ('pending', 'missed') RETURNING id`,
    [status, reason ?? null, userId, id]);
  if (r.rowCount) return { ok: true };
  const cur = await pool.query('SELECT status FROM collection_runs WHERE id = $1', [id]);
  if (!cur.rowCount) return { notFound: true };
  return { already: cur.rows[0].status };
};