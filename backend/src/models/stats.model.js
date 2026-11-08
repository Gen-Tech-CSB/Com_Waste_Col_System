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