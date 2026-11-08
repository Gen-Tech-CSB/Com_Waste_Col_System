const router = require('express').Router();
const user = require('../controllers/user.controller');
const { requireAuth, requireRole } = require('../middleware/auth');

router.get('/collectors', requireAuth, requireRole('admin'), user.collectors);

module.exports = router;