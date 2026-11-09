const { z } = require('zod');
const Run = require('../models/run.model');
const User = require('../models/user.model');

const STATUSES = ['pending', 'collected', 'partial', 'not_collected', 'missed'];

const markSchema = z.object({
  status: z.enum(['collected', 'partial', 'not_collected']),
  reason: z.string().trim().max(255).optional(),
}).refine((d) => d.status === 'collected' || (d.reason && d.reason.length >= 3),
  { message: 'reason is required unless the area was fully collected', path: ['reason'] });

const listQuery = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD').optional(),
  status: z.enum(STATUSES).optional(),
  area_id: z.coerce.number().int().optional(),
});

const fail = (e, res) => {
  if (e.code && String(e.code).startsWith('22'))
    return res.status(400).json({ success: false, message: 'Invalid date' });
  console.error(e);
  res.status(500).json({ success: false, message: 'Server error' });
};

exports.today = async (req, res) => {
  try {
    await Run.ensureToday();
    await Run.markOverdue();
    res.json({ success: true, data: await Run.list() });
  } catch (e) { fail(e, res); }
};

exports.list = async (req, res) => {
  const q = listQuery.safeParse(req.query);
  if (!q.success)
    return res.status(400).json({ success: false, message: 'Invalid query', errors: q.error.issues });
  try {
    await Run.ensureToday();
    await Run.markOverdue();
    res.json({ success: true, data: await Run.list({
      date: q.data.date ?? null, status: q.data.status ?? null, areaId: q.data.area_id ?? null,
    }) });
  } catch (e) { fail(e, res); }
};

exports.mine = async (req, res) => {
  try {
    const me = await User.findById(req.user.id);
    if (!me?.area_id) return res.json({ success: true, data: [] });
    await Run.ensureToday();
    await Run.markOverdue();
    res.json({ success: true, data: await Run.listForArea(me.area_id, 7) });
  } catch (e) { fail(e, res); }
};

exports.mark = async (req, res) => {
  const id = Number(req.params.id);
  if (!Number.isInteger(id)) return res.status(404).json({ success: false, message: 'Run not found' });
  const p = markSchema.safeParse(req.body);
  if (!p.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  try {
    const out = await Run.mark(id, p.data.status, p.data.reason, req.user.id);
    if (out.notFound) return res.status(404).json({ success: false, message: 'Run not found' });
    if (out.already)
      return res.status(409).json({ success: false, message: `Already marked as ${out.already}` });
    res.json({ success: true, data: await Run.findById(id) });
  } catch (e) { fail(e, res); }
};