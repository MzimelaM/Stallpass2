const mysql = require('mysql2');

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '#Admin123',
  database: 'stallpass',
  port: 3306
});

db.connect((err) => {
  if (err) return console.error('Connection error:', err);
  console.log('✅ Connected to database successfully!');
  db.end();
});
