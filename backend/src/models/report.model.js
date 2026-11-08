const pool = require('../db/pool');

const TRANSITIONS = {
  submitted: ['under_review', 'rejected'],
  under_review: ['in_progress', 'resolved', 'rejected'],
  in_progress: ['resolved', 'rejected'],
  resolved: [],
  rejected: [],
};

const FROM = `FROM reports r
  JOIN users u ON u.id = r.user_id
  JOIN areas a ON a.id = r.area_id
  JOIN barangays b ON b.id = a.barangay_id
  LEFT JOIN users c ON c.id = r.assigned_to`;

exports.create = async (d) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const r = await client.query(
      `INSERT INTO reports (user_id, area_id, category, description, location_note, latitude, longitude)
       VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id`,
      [d.userId, d.areaId, d.category, d.description,
       d.locationNote ?? null, d.latitude ?? null, d.longitude ?? null]);
    const id = r.rows[0].id;
    for (const p of d.photoPaths) {
      await client.query('INSERT INTO report_photos (report_id, file_path) VALUES ($1, $2)', [id, p]);
    }
    await client.query(
      `INSERT INTO report_status_history (report_id, status, remarks, changed_by)
       VALUES ($1, 'submitted', 'Report submitted', $2)`, [id, d.userId]);
    await client.query('COMMIT');
    return id;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

exports.findById = async (id) => {
  const r = await pool.query(
    `SELECT r.id, r.reference_no, r.user_id, u.full_name AS reporter_name,
        r.area_id, a.name AS area_name, b.name AS barangay_name,
        r.category, r.description, r.location_note,
        r.latitude::float8 AS latitude, r.longitude::float8 AS longitude,
        r.status, r.assigned_to, c.full_name AS assigned_to_name,
        r.created_at, r.updated_at,
        COALESCE((SELECT json_agg(p.file_path ORDER BY p.id)
                  FROM report_photos p WHERE p.report_id = r.id), '[]'::json) AS photos,
        COALESCE((SELECT json_agg(json_build_object(
                    'status', h.status, 'remarks', h.remarks,
                    'changed_by_name', hu.full_name, 'changed_at', h.changed_at) ORDER BY h.id)
                  FROM report_status_history h
                  LEFT JOIN users hu ON hu.id = h.changed_by
                  WHERE h.report_id = r.id), '[]'::json) AS history
     ${FROM}
     WHERE r.id = $1`, [id]);
  return r.rows[0];
};

exports.list = async ({ userId = null, status = null, category = null, areaId = null, q = null, limit, offset }) => {
  const params = [userId, status, category, areaId, q];
  const where = `WHERE ($1::int IS NULL OR r.user_id = $1)
    AND ($2::report_status IS NULL OR r.status = $2)
    AND ($3::report_category IS NULL OR r.category = $3)
    AND ($4::int IS NULL OR r.area_id = $4)
    AND ($5::text IS NULL
         OR r.reference_no ILIKE '%' || $5 || '%'
         OR r.description ILIKE '%' || $5 || '%'
         OR u.full_name ILIKE '%' || $5 || '%')`;

  const rows = await pool.query(
    `SELECT r.id, r.reference_no, r.category, r.status, r.description,
        r.area_id, a.name AS area_name, b.name AS barangay_name,
        u.full_name AS reporter_name, r.assigned_to, c.full_name AS assigned_to_name,
        r.created_at, r.updated_at,
        (SELECT COUNT(*)::int FROM report_photos p WHERE p.report_id = r.id) AS photo_count,
        (SELECT p.file_path FROM report_photos p WHERE p.report_id = r.id ORDER BY p.id LIMIT 1) AS first_photo
     ${FROM}
     ${where}
     ORDER BY r.created_at DESC, r.id DESC
     LIMIT $6 OFFSET $7`, [...params, limit, offset]);

  const total = await pool.query(`SELECT COUNT(*)::int AS n ${FROM} ${where}`, params);
  return { rows: rows.rows, total: total.rows[0].n };
};

exports.changeStatus = async (id, status, remarks, adminId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const cur = await client.query('SELECT status FROM reports WHERE id = $1 FOR UPDATE', [id]);
    if (!cur.rowCount) {
      await client.query('ROLLBACK');
      return { notFound: true };
    }
    const from = cur.rows[0].status;
    if (!TRANSITIONS[from].includes(status)) {
      await client.query('ROLLBACK');
      return { invalid: true, from };
    }
    await client.query('UPDATE reports SET status = $1, updated_at = now() WHERE id = $2', [status, id]);
    await client.query(
      `INSERT INTO report_status_history (report_id, status, remarks, changed_by)
       VALUES ($1, $2, $3, $4)`, [id, status, remarks ?? null, adminId]);
    await client.query('COMMIT');
    return { ok: true };
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

exports.assign = async (id, collectorId, adminId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const rep = await client.query('SELECT status FROM reports WHERE id = $1 FOR UPDATE', [id]);
    if (!rep.rowCount) {
      await client.query('ROLLBACK');
      return { notFound: true };
    }
    const st = rep.rows[0].status;
    if (st === 'resolved' || st === 'rejected') {
      await client.query('ROLLBACK');
      return { closed: true, status: st };
    }
    const col = await client.query(
      "SELECT full_name FROM users WHERE id = $1 AND role = 'collector'", [collectorId]);
    if (!col.rowCount) {
      await client.query('ROLLBACK');
      return { badCollector: true };
    }
    await client.query('UPDATE reports SET assigned_to = $1, updated_at = now() WHERE id = $2', [collectorId, id]);
    await client.query(
      `INSERT INTO report_status_history (report_id, status, remarks, changed_by)
       VALUES ($1, $2, $3, $4)`, [id, st, `Assigned to ${col.rows[0].full_name}`, adminId]);
    await client.query('COMMIT');
    return { ok: true };
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};