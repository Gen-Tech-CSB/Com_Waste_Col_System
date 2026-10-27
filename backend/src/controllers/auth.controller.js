const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { z } = require('zod');
const User = require('../models/user.model');

const registerSchema = z.object({
  full_name: z.string().min(2),
  email: z.string().email(),
  password: z.string().min(8),
  area_id: z.number().int().optional(),
  phone: z.string().optional(),
});

exports.register = async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success)
    return res.status(400).json({ success: false, message: 'Invalid input', errors: parsed.error.issues });

  const { full_name, email, password, area_id, phone } = parsed.data;
  try {
    const password_hash = await bcrypt.hash(password, 10);
    const user = await User.create({ full_name, email, password_hash, area_id, phone });
    res.status(201).json({ success: true, data: user });
  } catch (e) {
    if (e.code === '23505')
      return res.status(409).json({ success: false, message: 'Email already registered' });
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password)
    return res.status(400).json({ success: false, message: 'Email and password required' });
  try {
    const user = await User.findByEmail(email);
    if (!user || !(await bcrypt.compare(password, user.password_hash)))
      return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN });
    res.json({ success: true, data: {
      token,
      user: { id: user.id, full_name: user.full_name, email: user.email, role: user.role, area_id: user.area_id },
    }});
  } catch (e) {
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.me = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user });
  } catch (e) {
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};