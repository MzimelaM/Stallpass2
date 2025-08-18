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
  password: 'Password', // <-- change to your MySQL root password
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
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'User already exists' });
      return res.status(500).json({ message: 'Database insert failed' });
    }
    res.status(201).json({ message: 'User registered successfully' });
  });
});

// ----------------------
// USER LOGIN
// ----------------------
app.post('/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.status(400).json({ message: 'Email and password required' });

  const query = 'SELECT * FROM users WHERE email = ? LIMIT 1';
  db.query(query, [email], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed' });
    if (results.length === 0) return res.status(401).json({ message: 'Invalid email or password' });

    const user = results[0];
    if (user.password !== password) return res.status(401).json({ message: 'Invalid email or password' });

    res.json({
      message: 'Login successful',
      user: {
        id: user.id,
        full_name: user.full_name,
        student_number: user.student_number,
        email: user.email,
      }
    });
  });
});

// ----------------------
// ADMIN SIGNUP
// ----------------------
app.post('/admin/signup', (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: name, email, password});
  }
  
  const query = 'INSERT INTO admins (name, email, password) VALUES (?, ?, ?)';
  db.query(query, [name, email, password], (err) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'Admin already exists' });
      return res.status(500).json({ message: 'Database insert failed' });
    }
    res.status(201).json({ message: 'Admin registered successfully' });
  });
});

// ----------------------
// ADMIN LOGIN
// ----------------------
app.post('/admin/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.status(400).json({ message: 'Email and password required' });

  const query = 'SELECT * FROM admins WHERE email = ? LIMIT 1';
  db.query(query, [email], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed' });
    if (results.length === 0) return res.status(401).json({ message: 'Invalid email or password' });

    const admin = results[0];
    if (admin.password !== password) return res.status(401).json({ message: 'Invalid email or password' });

    res.json({
      message: 'Login successful',
      admin: {
        id: admin.id,
        name: admin.name,
        email: admin.email,
      }
    });
  });
});

// ----------------------
// ATTENDANCE RECORDS
// ----------------------
app.post('/attendance', (req, res) => {
  const { user_id, scanned_data } = req.body;
  if (!user_id || !scanned_data) return res.status(400).json({ message: 'user_id and scanned_data required' });

  const query = 'INSERT INTO attendance_records (user_id, scanned_data) VALUES (?, ?)';
  db.query(query, [user_id, scanned_data], (err) => {
    if (err) return res.status(500).json({ message: 'Insert failed' });
    res.status(201).json({ message: 'Attendance recorded successfully' });
  });
});

app.get('/attendance', (req, res) => {
  const query = `
    SELECT a.id, a.scanned_data, a.scan_time, a.status,
           u.full_name, u.student_number, u.email
    FROM attendance_records a
    JOIN users u ON a.user_id = u.id
  `;
  db.query(query, (err, results) => {
    if (err) return res.status(500).json({ message: 'Query failed' });
    res.json(results);
  });
});

// ----------------------
// NOTIFICATIONS
// ----------------------
app.post('/notifications', (req, res) => {
  const { title, message, notification_time } = req.body;
  if (!title || !message || !notification_time) return res.status(400).json({ message: 'All fields required' });

  const query = 'INSERT INTO notifications (title, message, notification_time) VALUES (?, ?, ?)';
  db.query(query, [title, message, notification_time], (err) => {
    if (err) return res.status(500).json({ message: 'Insert failed' });
    res.status(201).json({ message: 'Notification created' });
  });
});

app.get('/notifications', (req, res) => {
  db.query('SELECT * FROM notifications', (err, results) => {
    if (err) return res.status(500).json({ message: 'Query failed' });
    res.json(results);
  });
});

// ----------------------
// DEPARTMENT ANNOUNCEMENTS
// ----------------------
app.post('/announcements', (req, res) => {
  const { title, event_date, event_time, location, description } = req.body;
  if (!title || !event_date || !event_time || !location) return res.status(400).json({ message: 'Title, date, time, and location required' });

  const query = 'INSERT INTO department_announcements (title, event_date, event_time, location, description) VALUES (?, ?, ?, ?, ?)';
  db.query(query, [title, event_date, event_time, location, description], (err) => {
    if (err) return res.status(500).json({ message: 'Insert failed' });
    res.status(201).json({ message: 'Announcement created' });
  });
});

app.get('/announcements', (req, res) => {
  db.query('SELECT * FROM department_announcements ORDER BY event_date, event_time', (err, results) => {
    if (err) return res.status(500).json({ message: 'Query failed' });
    res.json(results);
  });
});

// ----------------------
// EVENTS
// ----------------------
app.post('/events', (req, res) => {
  const { title, description, event_date, location } = req.body;
  if (!title || !event_date || !location) return res.status(400).json({ message: 'Title, date, and location required' });

  const query = 'INSERT INTO events (title, description, event_date, location) VALUES (?, ?, ?, ?)';
  db.query(query, [title, description, event_date, location], (err) => {
    if (err) return res.status(500).json({ message: 'Insert failed' });
    res.status(201).json({ message: 'Event created' });
  });
});

app.get('/events', (req, res) => {
  db.query('SELECT * FROM events ORDER BY event_date', (err, results) => {
    if (err) return res.status(500).json({ message: 'Query failed' });
    res.json(results);
  });
});

// ----------------------
// START SERVER
// ----------------------
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
