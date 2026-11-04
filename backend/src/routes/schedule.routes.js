const router = require('express').Router();
const schedule = require('../controllers/schedule.controller');
const { requireAuth, requireRole } = require('../middleware/auth');

router.get('/', requireAuth, schedule.list);
router.post('/', requireAuth, requireRole('admin'), schedule.create);
router.put('/:id', requireAuth, requireRole('admin'), schedule.update);
router.delete('/:id', requireAuth, requireRole('admin'), schedule.remove);

module.exports = router;