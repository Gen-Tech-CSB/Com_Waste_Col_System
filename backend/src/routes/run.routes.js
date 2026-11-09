const router = require('express').Router();
const run = require('../controllers/run.controller');
const { requireAuth, requireRole } = require('../middleware/auth');

router.get('/today', requireAuth, requireRole('admin', 'collector'), run.today);
router.get('/mine', requireAuth, requireRole('resident'), run.mine);
router.get('/', requireAuth, requireRole('admin'), run.list);
router.patch('/:id', requireAuth, requireRole('admin', 'collector'), run.mark);

module.exports = router;