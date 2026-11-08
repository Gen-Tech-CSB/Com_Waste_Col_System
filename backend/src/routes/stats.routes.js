const router = require('express').Router();
const stats = require('../controllers/stats.controller');
const { requireAuth, requireRole } = require('../middleware/auth');

router.get('/summary', requireAuth, requireRole('admin'), stats.summary);

module.exports = router;