const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');

exports.register = async (req, res) => {
  try {
    const { name, email, password, address } = req.body;
    
    // Check if user exists
    const [users] = await db.query('SELECT * FROM user WHERE email = ?', [email]);
    if (users.length > 0) return res.status(400).json({ error: 'Email exists' });

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert address
    const [addressResult] = await db.query(
      'INSERT INTO address SET ?',
      { street: address.street, city: address.city, state: address.state, zip: address.zip, country: address.country }
    );

    // Insert user
    const [userResult] = await db.query(
      'INSERT INTO user SET ?',
      { name, email, password: hashedPassword, address_id: addressResult.insertId }
    );

    // Generate JWT
    const token = jwt.sign({ id: userResult.insertId }, process.env.JWT_SECRET, { expiresIn: '1h' });

    res.status(201).json({ token });
  } catch (err) {
    res.status(500).json({ error: 'Registration failed' });
  }
};

// Add similar methods for login, password reset...