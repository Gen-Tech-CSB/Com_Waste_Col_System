const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const pool = require('./db/pool');
const path = require('path');


const app = express();
app.use(helmet());
app.use(cors());
app.use(express.json());

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ success: true, message: 'API and DB OK' });
  } catch (e) {
    console.error(e.message);
    res.status(500).json({ success: false, message: 'DB connection failed' });
  }
}); 

app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/areas', require('./routes/area.routes'));
app.use('/api/schedules', require('./routes/schedule.routes'));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads'), {
  setHeaders: (res) => res.set('Cross-Origin-Resource-Policy', 'cross-origin'),
}));
app.use('/api/reports', require('./routes/report.routes'));

app.use('/api', (req, res) => {
  res.status(404).json({ success: false, message: 'API endpoint not found' });
});

app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed')
    return res.status(400).json({ success: false, message: 'Invalid JSON request' });
  if (err.type === 'entity.too.large')
    return res.status(413).json({ success: false, message: 'Request is too large' });
  console.error(err.message);
  res.status(500).json({ success: false, message: 'Server error' });
});



module.exports = app;
