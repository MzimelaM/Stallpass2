const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '#Admin123',
  database: 'stallpass2',
  port: 3306
});

// Connect to MySQL
db.connect((err) => {
  if (err) {
    console.error('❌ Database connection error:', err);
    process.exit(1);
  }
  console.log('✅ Connected to MySQL database: stallpass2');
});

// ----------------------
// ROOT
// ----------------------
app.get('/', (req, res) => {
  res.send('Server is running and connected to MySQL!');
});

// ----------------------
// USER SIGNUP
// ----------------------
app.post('/signup', (req, res) => {
  const { full_name, student_number, email, password } = req.body;

  if (!full_name || !student_number || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const query = 'INSERT INTO users (full_name, student_number, email, password) VALUES (?, ?, ?, ?)';
  db.query(query, [full_name, student_number, email, password], (err) => {
    if (err) {
      console.error('Signup error:', err);
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'User already exists' });
      return res.status(500).json({ message: 'Database insert failed', error: err.sqlMessage });
    }
    res.status(201).json({ message: 'User registered successfully' });
  });
});
// ----------------------
// USER LOGIN
// ----------------------
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email and password required' });
  }

  const query = `
    SELECT id, full_name, student_number, email
    FROM users
    WHERE email = ? AND password = ?
    LIMIT 1
  `;

  db.query(query, [email, password], (err, results) => {
    if (err) {
      console.error('Login error:', err);
      return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    }

    if (results.length === 0) {
      return res.status(401).json({ message: 'Invalid email or password' });
    }

    const user = results[0];
    res.json({
      message: 'Login successful',
      userId: user.id,
      full_name: user.full_name,
      student_number: user.student_number,
      email: user.email,
    });
  });
});


// ----------------------
// GET USER BY ID
// ----------------------
app.get('/user/:id', (req, res) => {
  const userId = req.params.id;

  const query = 'SELECT id, full_name, student_number, email, password FROM users WHERE id = ? LIMIT 1';
  db.query(query, [userId], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(404).json({ message: 'User not found' });

    res.json(results[0]);
  });
});

// ----------------------
// UPDATE USER
// ----------------------
app.put('/user/:id', (req, res) => {
  const userId = req.params.id;
  const { full_name, student_number, email, password } = req.body;

  if (!full_name || !student_number || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const query = 'UPDATE users SET full_name = ?, student_number = ?, email = ?, password = ? WHERE id = ?';
  db.query(query, [full_name, student_number, email, password, userId], (err, result) => {
    if (err) return res.status(500).json({ message: 'Update failed', error: err.sqlMessage });

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    res.json({ message: 'Profile updated successfully' });
  });
});

// ----------------------
// START SERVER
// ----------------------
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
