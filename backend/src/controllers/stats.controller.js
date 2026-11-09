const { z } = require('zod');
const Stats = require('../models/stats.model');

const monthSchema = z.object({
  month: z.string().regex(/^\d{4}-(0[1-9]|1[0-2])$/, 'Use YYYY-MM').optional(),
});

const fail = (e, res) => {
  console.error(e);
  res.status(500).json({ success: false, message: 'Server error' });
};

exports.summary = async (req, res) => {
  try {
    res.json({ success: true, data: await Stats.summary() });
  } catch (e) { fail(e, res); }
};

exports.monthly = async (req, res) => {
  const q = monthSchema.safeParse(req.query);
  if (!q.success)
    return res.status(400).json({ success: false, message: 'Invalid month, use YYYY-MM', errors: q.error.issues });
  try {
    const month = q.data.month ?? await Stats.currentMonth();
    res.json({ success: true, data: await Stats.monthly(month) });
  } catch (e) { fail(e, res); }
};

const csvCell = (v) => {
  let s = v === null || v === undefined ? '' : String(v);
  if (/^[=+\-@]/.test(s)) s = `'${s}`;
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
};

exports.monthlyCsv = async (req, res) => {
  const q = monthSchema.safeParse(req.query);
  if (!q.success)
    return res.status(400).json({ success: false, message: 'Invalid month, use YYYY-MM', errors: q.error.issues });
  try {
    const month = q.data.month ?? await Stats.currentMonth();
    const d = await Stats.monthly(month);
    const rows = [
      ['section', 'item', 'value'],
      ['Month', 'month', d.month],
      ['Reports', 'total', d.reports.total],
      ...Object.entries(d.reports.by_status).map(([k, v]) => ['Reports by status', k, v]),
      ...Object.entries(d.reports.by_category).map(([k, v]) => ['Reports by category', k, v]),
      ['Reports', 'resolution_rate_percent', d.reports.resolution_rate],
      ['Reports', 'avg_resolution_hours', d.reports.avg_resolution_hours],
      ...d.reports.by_barangay.map((b) => ['Reports by barangay', b.barangay, `${b.resolved} of ${b.total} resolved`]),
      ...['pending', 'collected', 'partial', 'not_collected', 'missed', 'total_due']
        .map((k) => ['Collections', k, d.collections[k]]),
      ['Collections', 'completion_rate_percent', d.collections.completion_rate],
      ...d.collections.by_barangay.map((b) => ['Collections by barangay (percent)', b.barangay, b.completion_rate]),
    ];
    res.set({
      'Content-Type': 'text/csv; charset=utf-8',
      'Content-Disposition': `attachment; filename="monthly-report-${d.month}.csv"`,
    });
    res.send('\ufeff' + rows.map((r) => r.map(csvCell).join(',')).join('\r\n'));
  } catch (e) { fail(e, res); }
};