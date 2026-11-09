const pool = require('../db/pool');

exports.summary = async () => {
  const [st, cat, open] = await Promise.all([
    pool.query('SELECT status, COUNT(*)::int AS n FROM reports GROUP BY status'),
    pool.query('SELECT category, COUNT(*)::int AS n FROM reports GROUP BY category'),
    pool.query(`SELECT COUNT(*)::int AS n FROM reports
                WHERE assigned_to IS NULL AND status NOT IN ('resolved', 'rejected')`),
  ]);
  const by_status = { submitted: 0, under_review: 0, in_progress: 0, resolved: 0, rejected: 0 };
  st.rows.forEach((r) => { by_status[r.status] = r.n; });
  const by_category = { missed_pickup: 0, illegal_dumping: 0, overflowing_bin: 0, other: 0 };
  cat.rows.forEach((r) => { by_category[r.category] = r.n; });
  const total = Object.values(by_status).reduce((a, b) => a + b, 0);
  return { total, by_status, by_category, unassigned_open: open.rows[0].n };
};


const RANGE_R = `(r.created_at AT TIME ZONE 'Asia/Manila') >= $1::date
  AND (r.created_at AT TIME ZONE 'Asia/Manila') < ($1::date + interval '1 month')`;
const RANGE_RUN = `cr.run_date >= $1::date AND cr.run_date < ($1::date + interval '1 month')`;

exports.currentMonth = async () => {
  const r = await pool.query("SELECT to_char(now() AT TIME ZONE 'Asia/Manila', 'YYYY-MM') AS m");
  return r.rows[0].m;
};

const pct = (a, b) => (b === 0 ? null : Math.round((a / b) * 1000) / 10);

exports.monthly = async (month) => {
  const first = `${month}-01`;
  const [st, cat, brgy, avg, runs, runBrgy] = await Promise.all([
    pool.query(`SELECT r.status, COUNT(*)::int AS n FROM reports r WHERE ${RANGE_R} GROUP BY r.status`, [first]),
    pool.query(`SELECT r.category, COUNT(*)::int AS n FROM reports r WHERE ${RANGE_R} GROUP BY r.category`, [first]),
    pool.query(
      `SELECT b.name AS barangay, COUNT(*)::int AS total,
          COUNT(*) FILTER (WHERE r.status = 'resolved')::int AS resolved
       FROM reports r
       JOIN areas a ON a.id = r.area_id
       JOIN barangays b ON b.id = a.barangay_id
       WHERE ${RANGE_R} GROUP BY b.name ORDER BY b.name`, [first]),
    pool.query(
      `SELECT ROUND(AVG(EXTRACT(EPOCH FROM (h.changed_at - r.created_at)) / 3600)::numeric, 1)::float8 AS hours
       FROM reports r
       JOIN report_status_history h ON h.report_id = r.id AND h.status = 'resolved'
       WHERE ${RANGE_R}`, [first]),
    pool.query(`SELECT cr.status, COUNT(*)::int AS n FROM collection_runs cr WHERE ${RANGE_RUN} GROUP BY cr.status`, [first]),
    pool.query(
      `SELECT b.name AS barangay,
          COUNT(*) FILTER (WHERE cr.status <> 'pending')::int AS due,
          COUNT(*) FILTER (WHERE cr.status = 'collected')::int AS collected
       FROM collection_runs cr
       JOIN collection_schedules s ON s.id = cr.schedule_id
       JOIN areas a ON a.id = s.area_id
       JOIN barangays b ON b.id = a.barangay_id
       WHERE ${RANGE_RUN} GROUP BY b.name ORDER BY b.name`, [first]),
  ]);

  const by_status = { submitted: 0, under_review: 0, in_progress: 0, resolved: 0, rejected: 0 };
  st.rows.forEach((r) => { by_status[r.status] = r.n; });
  const by_category = { missed_pickup: 0, illegal_dumping: 0, overflowing_bin: 0, other: 0 };
  cat.rows.forEach((r) => { by_category[r.category] = r.n; });
  const total = Object.values(by_status).reduce((a, b) => a + b, 0);

  const c = { pending: 0, collected: 0, partial: 0, not_collected: 0, missed: 0 };
  runs.rows.forEach((r) => { c[r.status] = r.n; });
  const due = c.collected + c.partial + c.not_collected + c.missed;

  return {
    month,
    reports: {
      total,
      by_status,
      by_category,
      resolution_rate: pct(by_status.resolved, total),
      avg_resolution_hours: avg.rows[0].hours,
      by_barangay: brgy.rows,
    },
    collections: {
      ...c,
      total_due: due,
      completion_rate: pct(c.collected, due),
      by_barangay: runBrgy.rows.map((x) => ({
        barangay: x.barangay, due: x.due, collected: x.collected, completion_rate: pct(x.collected, x.due),
      })),
    },
  };
};