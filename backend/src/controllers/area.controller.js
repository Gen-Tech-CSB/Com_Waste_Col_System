const Area = require('../models/area.model');

exports.list = async (req, res) => {
  try {
    res.json({ success: true, data: await Area.listAll() });
  } catch (e) {
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};