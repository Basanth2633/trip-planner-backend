const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();
require('dotenv').config();
console.log('DB_NAME from .env:', process.env.DB_NAME); // Should log "team_3"
console.log('All env vars:', process.env);   // Check if .env is loaded

const app = express();
app.use(cors());
app.use(bodyParser.json());

 
 

// Database connection
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost' ,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'Niny#2633',
  database:process.env.DB_NAME || 'team_3',
  waitForConnections: true,
  connectionLimit: 10
});

// Registration endpoint
app.post('/api/register', async (req, res) => {
  const { name, email, password, street, city, state, zip, country } = req.body;

  try {
    // 1. Hash password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 2. Start transaction
    const conn = await pool.getConnection();
    await conn.beginTransaction();

    try {
      // 3. Insert address
      const [addressResult] = await conn.query(
        'INSERT INTO address (number, street, city, state, zip, country) VALUES (?, ?, ?, ?, ?, ?)',
        ['', street, city, state, zip, country]
      );

      // 4. Insert user
      const [userResult] = await conn.query(
        'INSERT INTO user (name, email, password, address_id) VALUES (?, ?, ?, ?)',
        [name, email, hashedPassword, addressResult.insertId]
      );

      // 5. Commit transaction
      await conn.commit();
      conn.release();

      res.status(201).json({ 
        success: true,
        userId: userResult.insertId
      });

    } catch (err) {
      await conn.rollback();
      conn.release();
      throw err;
    }

  } catch (err) {
    console.error('Registration error:', err);
    
    // Handle duplicate email
    if (err.code === 'ER_DUP_ENTRY') {
      return res.status(400).json({ error: 'Email already exists' });
    }
    
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Login endpoint
app.post('/api/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    // 1. Check if user exists
    const [users] = await pool.query(
      'SELECT * FROM user WHERE email = ?', 
      [email]
    );

    if (users.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    const user = users[0];

    // 2. Verify password (compare with bcrypt)
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Invalid email or password' });
    }

    // 3. Successful login (return user data, excluding password)
    const { password: _, ...userData } = user; // Remove password from response
    res.status(200).json({ 
      success: true, 
      message:'logged in successfully',
      user: userData 
    });

  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Login failed' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));