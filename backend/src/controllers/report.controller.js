const fs = require('fs');
const { z } = require('zod');
const Report = require('../models/report.model');
const User = require('../models/user.model');

const CATEGORIES = ['missed_pickup', 'illegal_dumping', 'overflowing_bin', 'other'];
const STATUSES = ['submitted', 'under_review', 'in_progress', 'resolved', 'rejected'];

const createSchema = z.object({
  category: z.enum(CATEGORIES),
  description: z.string().trim().min(5).max(1000),
  area_id: z.number().int().optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  location_note: z.string().trim().max(255).optional(),
}).refine((d) => (d.latitude === undefined) === (d.longitude === undefined),
  { message: 'latitude and longitude must be sent together' });

const listQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
  status: z.enum(STATUSES).optional(),
  category: z.enum(CATEGORIES).optional(),
  area_id: z.coerce.number().int().optional(),
  q: z.string().trim().max(100).optional(),
});

const statusSchema = z.object({
  status: z.enum(STATUSES),
  remarks: z.string().trim().max(500).optional(),
}).refine((d) => d.status !== 'rejected' || (d.remarks && d.remarks.length >= 3),
  { message: 'remarks are required when rejecting a report', path: ['remarks'] });

const num = (v) => (v === undefined || v === '' ? undefined : Number(v));
const removeFiles = (files = []) => files.forEach((f) => fs.unlink(f.path, () => {}));
const serverError = (e, res) => {
  console.error(e);
  res.status(500).json({ success: false, message: 'Server error' });
};

exports.create = async (req, res) => {
  const files = req.files || [];
  const b = req.body || {};
  const p = createSchema.safeParse({
    category: b.category,
    description: b.description,
    area_id: num(b.area_id),
    latitude: num(b.latitude),
    longitude: num(b.longitude),
    location_note: b.location_note === '' ? undefined : b.location_note,
  });
  if (!p.success) {
    removeFiles(files);
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  }
  const d = p.data;
  try {
    let areaId = d.area_id;
    if (areaId === undefined) {
      const me = await User.findById(req.user.id);
      areaId = me?.area_id;
    }
    if (!areaId) {
      removeFiles(files);
      return res.status(400).json({ success: false, message: 'area_id is required' });
    }
    const id = await Report.create({
      userId: req.user.id,
      areaId,
      category: d.category,
      description: d.description,
      locationNote: d.location_note,
      latitude: d.latitude,
      longitude: d.longitude,
      photoPaths: files.map((f) => `/uploads/reports/${f.filename}`),
    });
    res.status(201).json({ success: true, data: await Report.findById(id) });
  } catch (e) {
    removeFiles(files);
    if (e.code === '23503')
      return res.status(400).json({ success: false, message: 'Area does not exist' });
    serverError(e, res);
  }
};

const sendList = async (res, q, userId) => {
  const { rows, total } = await Report.list({
    userId,
    status: q.status ?? null,
    category: q.category ?? null,
    q: q.q || null,
    areaId: userId ? null : (q.area_id ?? null),
    limit: q.limit,
    offset: (q.page - 1) * q.limit,
  });
  res.json({ success: true, data: rows, meta: { page: q.page, limit: q.limit, total } });
};

exports.mine = async (req, res) => {
  const q = listQuery.safeParse(req.query);
  if (!q.success)
    return res.status(400).json({ success: false, message: 'Invalid query', errors: q.error.issues });
  try { await sendList(res, q.data, req.user.id); } catch (e) { serverError(e, res); }
};

exports.listAll = async (req, res) => {
  const q = listQuery.safeParse(req.query);
  if (!q.success)
    return res.status(400).json({ success: false, message: 'Invalid query', errors: q.error.issues });
  try { await sendList(res, q.data, null); } catch (e) { serverError(e, res); }
};

exports.getOne = async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(404).json({ success: false, message: 'Report not found' });
  try {
    const r = await Report.findById(id);
    if (!r || (req.user.role === 'resident' && r.user_id !== req.user.id))
      return res.status(404).json({ success: false, message: 'Report not found' });
    res.json({ success: true, data: r });
  } catch (e) { serverError(e, res); }
};

exports.updateStatus = async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(404).json({ success: false, message: 'Report not found' });
  const p = statusSchema.safeParse(req.body);
  if (!p.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  try {
    const out = await Report.changeStatus(id, p.data.status, p.data.remarks, req.user.id);
    if (out.notFound) return res.status(404).json({ success: false, message: 'Report not found' });
    if (out.invalid)
      return res.status(409).json({ success: false, message: `Cannot change status from ${out.from} to ${p.data.status}` });
    res.json({ success: true, data: await Report.findById(id) });
  } catch (e) { serverError(e, res); }
};

const assignSchema = z.object({ collector_id: z.number().int() });

exports.assign = async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(404).json({ success: false, message: 'Report not found' });
  const p = assignSchema.safeParse(req.body);
  if (!p.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  try {
    const out = await Report.assign(id, p.data.collector_id, req.user.id);
    if (out.notFound) return res.status(404).json({ success: false, message: 'Report not found' });
    if (out.closed)
      return res.status(409).json({ success: false, message: `Cannot assign a ${out.status} report` });
    if (out.badCollector)
      return res.status(400).json({ success: false, message: 'collector_id must belong to a collector account' });
    res.json({ success: true, data: await Report.findById(id) });
  } catch (e) { serverError(e, res); }
};