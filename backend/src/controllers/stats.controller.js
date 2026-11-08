const Stats = require('../models/stats.model');

exports.summary = async (req, res) => {
  try {
    res.json({ success: true, data: await Stats.summary() });
  } catch (e) {
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};