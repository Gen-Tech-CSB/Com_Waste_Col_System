require('dotenv').config();
const cron = require('node-cron');
const app = require('./src/app');
const Run = require('./src/models/run.model');

if (!process.env.JWT_SECRET || process.env.JWT_SECRET.length < 16)
  console.warn('WARNING: JWT_SECRET is missing or shorter than 16 characters. Use a long random value.');

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

const tick = () => Run.ensureToday()
  .then(() => Run.markOverdue())
  .catch((e) => console.error('runs job failed:', e.message));
cron.schedule('*/15 * * * *', tick);
tick(); 

