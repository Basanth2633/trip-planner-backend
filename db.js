const mysql = require('mysql2/promise');
require('dotenv').config();


const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root', // Default MySQL username
  password: process.env.DB_PASSWORD || 'Niny#2633', // Your MySQL password
  database: process.env.DB_NAME || 'team_3',
  waitForConnections: true,
  connectionLimit: 10
});
module.exports = pool;