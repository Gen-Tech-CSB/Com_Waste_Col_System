const path = require('path');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const pool = require('./db/pool');

const app = express();
if (process.env.TRUST_PROXY) app.set('trust proxy', Number(process.env.TRUST_PROXY));
app.use(helmet());
app.use(cors());
app.use(express.json());

const limiter = (limit, message, skipSuccessfulRequests = false) => rateLimit({
  windowMs: 15 * 60 * 1000,
  limit,
  skipSuccessfulRequests,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message },
});
app.use('/api/auth/login',
  limiter(Number(process.env.LOGIN_RATE_LIMIT) || 10, 'Too many failed login attempts, try again in 15 minutes', true));
app.use('/api/auth/register',
  limiter(Number(process.env.REGISTER_RATE_LIMIT) || 20, 'Too many sign-up attempts, try again in 15 minutes'));

app.get('/api/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ success: true, message: 'API and DB OK' });
  } catch (e) {
    console.error(e.message);
    res.status(500).json({ success: false, message: 'DB connection failed' });
  }
});

app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads'), {
  setHeaders: (res) => res.set('Cross-Origin-Resource-Policy', 'cross-origin'),
}));

app.use('/api/auth', require('./routes/auth.routes'));
app.use('/api/areas', require('./routes/area.routes'));
app.use('/api/schedules', require('./routes/schedule.routes'));
app.use('/api/reports', require('./routes/report.routes'));
app.use('/api/stats', require('./routes/stats.routes'));
app.use('/api/users', require('./routes/user.routes'));
app.use('/api/runs', require('./routes/run.routes'));

app.use('/api', (req, res) => res.status(404).json({ success: false, message: 'Route not found' }));

app.use((err, req, res, next) => {
  if (res.headersSent) return next(err);
  if (err.type === 'entity.parse.failed')
    return res.status(400).json({ success: false, message: 'Invalid JSON body' });
  if (err.type === 'entity.too.large')
    return res.status(413).json({ success: false, message: 'Request body too large' });
  console.error(err);
  res.status(500).json({ success: false, message: 'Server error' });
});

module.exports = app;