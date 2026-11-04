const router = require('express').Router();
const area = require('../controllers/area.controller');

router.get('/', area.list);

module.exports = router;