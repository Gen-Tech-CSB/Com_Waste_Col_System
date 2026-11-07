const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const multer = require('multer');

const DIR = path.join(__dirname, '..', '..', 'uploads', 'reports');
fs.mkdirSync(DIR, { recursive: true });

const EXT = { 'image/jpeg': '.jpg', 'image/png': '.png', 'image/webp': '.webp' };

const upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => cb(null, DIR),
    filename: (req, file, cb) => cb(null, crypto.randomUUID() + EXT[file.mimetype]),
  }),
  fileFilter: (req, file, cb) => {
    if (EXT[file.mimetype]) return cb(null, true);
    const e = new Error('Only JPG, PNG, or WEBP images are allowed');
    e.code = 'BAD_FILE_TYPE';
    cb(e);
  },
  limits: { fileSize: 5 * 1024 * 1024, files: 3 },
});

exports.uploadPhotos = (req, res, next) => {
  upload.array('photos', 3)(req, res, (err) => {
    if (!err) return next();
    if (err.code === 'LIMIT_FILE_SIZE')
      return res.status(400).json({ success: false, message: 'Each photo must be 5 MB or smaller' });
    if (err.code === 'LIMIT_UNEXPECTED_FILE' || err.code === 'LIMIT_FILE_COUNT')
      return res.status(400).json({ success: false, message: 'Up to 3 photos only, using the field name "photos"' });
    if (err.code === 'BAD_FILE_TYPE')
      return res.status(400).json({ success: false, message: err.message });
    console.error(err);
    res.status(500).json({ success: false, message: 'Upload failed' });
  });
};