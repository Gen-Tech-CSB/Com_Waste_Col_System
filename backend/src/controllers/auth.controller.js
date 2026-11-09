const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { z } = require('zod');
const User = require('../models/user.model');

const registerSchema = z.object({
  full_name: z.string().trim().min(2).max(150),
  email: z.string().trim().toLowerCase().email().max(150),
  password: z.string().min(8).refine(value => Buffer.byteLength(value, 'utf8') <= 72,
    'Password must be 72 UTF-8 bytes or fewer'),
  area_id: z.number().int().positive().optional(),
  phone: z.string().trim().max(20).optional(),
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
    if (e.code === '23503')
      return res.status(400).json({ success: false, message: 'Choose an existing collection area',
        errors: [{ path: ['area_id'], message: 'This collection area is no longer available' }] });
    console.error(e);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

exports.login = async (req, res) => {
  const parsed = z.object({ email: z.string().trim().toLowerCase().email().max(150),
    password: z.string().min(1).max(1024) }).safeParse(req.body);
  if (!parsed.success)
    return res.status(400).json({ success: false, message: 'Enter a valid email and password' });
  const { email, password } = parsed.data;
  try {
    const user = await User.findByEmail(email);
    if (!user || !(await bcrypt.compare(password, user.password_hash)))
      return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '1d' });
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

const profileSchema = z.object({
  full_name: z.string().trim().min(2).max(150).optional(),
  phone: z.string().trim().max(20).nullable().optional(),
  area_id: z.number().int().positive().nullable().optional(),
}).strict().refine(data => Object.keys(data).length > 0, 'Send at least one profile field');

exports.updateMe = async (req, res) => {
  const parsed = profileSchema.safeParse(req.body);
  if (!parsed.success)
    return res.status(400).json({ success: false, message: 'Check your profile details', errors: parsed.error.issues });
  try {
    const user = await User.updateProfile(req.user.id, parsed.data);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: user });
  } catch (error) {
    if (error.code === '23503')
      return res.status(400).json({ success: false, message: 'Choose an existing collection area',
        errors: [{ path: ['area_id'], message: 'This collection area is no longer available' }] });
    console.error(error.message);
    res.status(500).json({ success: false, message: 'Could not save your profile' });
  }
};
