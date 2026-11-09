const router = require('express').Router();
const stats = require('../controllers/stats.controller');
const { requireAuth, requireRole } = require('../middleware/auth');

router.get('/summary', requireAuth, requireRole('admin'), stats.summary);

router.get('/monthly', requireAuth, requireRole('admin'), stats.monthly);
router.get('/monthly/export', requireAuth, requireRole('admin'), stats.monthlyCsv);

module.exports = router;