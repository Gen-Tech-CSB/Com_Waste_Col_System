const User = require('../models/user.model');

exports.collectors = async (req, res) => {
  try {
    res.json({ success: true, data: await User.listCollectors() });
  } catch (e) {
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};