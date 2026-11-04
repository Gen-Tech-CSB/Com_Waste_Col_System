const { z } = require('zod');
const Schedule = require('../models/schedule.model');
const User = require('../models/user.model');

const time = z.string().regex(/^([01]\d|2[0-3]):[0-5]\d$/, 'Use HH:MM');
const WASTE = ['biodegradable', 'non_biodegradable', 'recyclable', 'special'];

const wasteTypes = z.array(z.enum(WASTE)).min(1)
  .transform((a) => [...new Set(a)])
  .default(['biodegradable', 'non_biodegradable', 'recyclable']);

const common = {
  day_of_week: z.number().int().min(0).max(6),
  start_time: time,
  end_time: time,
  waste_types: wasteTypes,
  is_active: z.boolean().optional(),
};

const createSchema = z.object({
  ...common,
  area_ids: z.array(z.number().int()).min(1).transform((a) => [...new Set(a)]),
});
const updateSchema = z.object({ ...common, area_id: z.number().int() });

const handleError = (e, res) => {
  if (e.code === '23503')
    return res.status(400).json({ success: false, message: 'Area does not exist' });
  if (e.code === '23514')
    return res.status(400).json({ success: false, message: 'end_time must be after start_time' });
  if (e.code === '23505')
    return res.status(409).json({ success: false, message: 'A schedule for that area, day, and start time already exists' });
  console.error(e);
  res.status(500).json({ success: false, message: 'Server error' });
};

exports.list = async (req, res) => {
  try {
    let areaId = req.query.area_id ? Number(req.query.area_id) : null;
    let activeOnly = false;

    if (req.user.role === 'resident') {
      const me = await User.findById(req.user.id);
      areaId = me?.area_id ?? null;
      activeOnly = true;
      if (!areaId) return res.json({ success: true, data: [] });
    }
    res.json({ success: true, data: await Schedule.list({ areaId, activeOnly }) });
  } catch (e) { handleError(e, res); }
};

exports.create = async (req, res) => {
  const p = createSchema.safeParse(req.body);
  if (!p.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  const { area_ids, ...rest } = p.data;
  try {
    res.status(201).json({ success: true, data: await Schedule.createMany(area_ids, rest) });
  } catch (e) { handleError(e, res); }
};

exports.update = async (req, res) => {
  const p = updateSchema.safeParse(req.body);
  if (!p.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: p.error.issues });
  try {
    const row = await Schedule.update(Number(req.params.id), p.data);
    if (!row) return res.status(404).json({ success: false, message: 'Schedule not found' });
    res.json({ success: true, data: row });
  } catch (e) { handleError(e, res); }
};

exports.remove = async (req, res) => {
  try {
    const ok = await Schedule.remove(Number(req.params.id));
    if (!ok) return res.status(404).json({ success: false, message: 'Schedule not found' });
    res.json({ success: true, message: 'Schedule deleted' });
  } catch (e) { handleError(e, res); }
};