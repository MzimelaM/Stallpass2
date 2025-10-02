const mysql = require('mysql2');

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '#Admin123',
  database: 'stallpass2', // make sure this is your actual DB name
  port: 3306
});

// Connect to MySQL
db.connect((err) => {
  if (err) {
    console.error('❌ Database connection error:', err);
    process.exit(1);
  }
  console.log('✅ Connected to MySQL database');
});

// Test insert
const testUser = {
  full_name: 'Test User',
  student_number: 'node23456',
  email: 'test@example.com',
  password: 'password123'
};

const query = 'INSERT INTO users (full_name, student_number, email, password) VALUES (?, ?, ?, ?)';

db.query(query, [testUser.full_name, testUser.student_number, testUser.email, testUser.password], (err, results) => {
  if (err) {
    console.error('❌ Database insert failed:', err);
  } else {
    console.log('✅ User inserted successfully:', results);
  }
  db.end(); // close connection
});
