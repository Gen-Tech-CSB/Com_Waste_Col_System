const router = require('express').Router();
const report = require('../controllers/report.controller');
const { requireAuth, requireRole } = require('../middleware/auth');
const { uploadPhotos } = require('../middleware/upload');

router.post('/', requireAuth, requireRole('resident'), uploadPhotos, report.create);
router.get('/mine', requireAuth, requireRole('resident'), report.mine);
router.get('/', requireAuth, requireRole('admin', 'collector'), report.listAll);
router.get('/:id', requireAuth, report.getOne);
router.patch('/:id/status', requireAuth, requireRole('admin'), report.updateStatus);
router.patch('/:id/assign', requireAuth, requireRole('admin'), report.assign);

module.exports = router;