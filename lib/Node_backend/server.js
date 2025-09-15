const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '2004',
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

  const query = 'INSERT INTO students (student_number, full_name, email, password) VALUES (?, ?, ?, ?)';
  db.query(query, [student_number, full_name, email, password], (err) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'Student already exists' });
      return res.status(500).json({ message: 'Database insert failed', error: err.sqlMessage });
    }
    res.status(201).json({ message: 'Student registered successfully' });
  });
});


// ----------------------
// USER LOGIN
// ----------------------
app.post('/login', (req, res) => {
  const { student_number, password } = req.body;

  if (!student_number || !password) {
    return res.status(400).json({ message: 'Student number and password required' });
  }

  const query = `
    SELECT student_number, full_name, email
    FROM students
    WHERE student_number = ? AND password = ?
    LIMIT 1
  `;

  db.query(query, [student_number, password], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(401).json({ message: 'Invalid student number or password' });

    const user = results[0];
    res.json({
      message: 'Login successful',
      student_number: user.student_number,
      full_name: user.full_name,
      email: user.email,
    });
  });
});

// ----------------------
// GET USER BY STUDENT NUMBER
// ----------------------
app.get('/user/:student_number', (req, res) => {
  const student_number = req.params.student_number;
  const query = 'SELECT student_number, full_name, email, password FROM students WHERE student_number = ? LIMIT 1';
  db.query(query, [student_number], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(404).json({ message: 'Student not found' });
    res.json(results[0]);
  });
});

// ----------------------
// UPDATE USER
// ----------------------
app.put('/user/:student_number', (req, res) => {
  const student_number = req.params.student_number;
  const { full_name, email, password } = req.body;

  if (!full_name || !student_number || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  const query = 'UPDATE students SET full_name = ?, email = ?, password = ? WHERE student_number = ?';
  db.query(query, [full_name, email, password, student_number], (err, result) => {
    if (err) return res.status(500).json({ message: 'Update failed', error: err.sqlMessage });
    if (result.affectedRows === 0) return res.status(404).json({ message: 'Student not found' });
    res.json({ message: 'Profile updated successfully' });
  });
});

// ----------------------
// LECTURER SIGNUP
// ----------------------
app.post('/lecturer/signup', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'All fields are required' });

  const hashedPassword = await bcrypt.hash(password, 10);
  const query = 'INSERT INTO lecturers (email, password) VALUES (?, ?)';
  db.query(query, [email, hashedPassword], (err) => {
    if (err) {
      if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'Email already exists' });
      return res.status(500).json({ message: 'Database insert failed', error: err.sqlMessage });
    }
    res.status(201).json({ message: 'Lecturer registered successfully' });
  });
});

// ----------------------
// GET/UPDATE LECTURER
// ----------------------
app.get('/lecturer/:id', (req, res) => {
  const id = req.params.id;
  const query = 'SELECT lecturer_id, email FROM lecturers WHERE lecturer_id = ? LIMIT 1';
  db.query(query, [id], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(404).json({ message: 'Lecturer not found' });
    res.json(results[0]);
  });
});

app.put('/lecturer/:id', async (req, res) => {
  const id = req.params.id;
  const { email, password } = req.body;
  if (!email || !password) return res.status(400).json({ message: 'All fields are required' });

  const hashedPassword = await bcrypt.hash(password, 10);
  const query = 'UPDATE lecturers SET email = ?, password = ? WHERE lecturer_id = ?';
  db.query(query, [email, hashedPassword, id], (err, result) => {
    if (err) return res.status(500).json({ message: 'Update failed', error: err.sqlMessage });
    if (result.affectedRows === 0) return res.status(404).json({ message: 'Lecturer not found' });
    res.json({ message: 'Profile updated successfully' });
  });
});

// ----------------------
// GET UPCOMING EVENTS
// ----------------------
app.get('/get_events', (req, res) => {
  const now = new Date().toISOString();
  const sql = `
    SELECT event_id, event_name, event_date, event_code
    FROM events
    WHERE event_date >= ?
    ORDER BY event_date ASC
  `;
  db.query(sql, [now], (err, results) => {
    if (err) return res.status(500).json({ message: err.sqlMessage });
    res.json(results);
  });
});

// ----------------------
// CREATE EVENT
// ----------------------
app.post('/create_event', (req, res) => {
  const { event_name, event_date } = req.body;
  if (!event_name || !event_date) return res.status(400).json({ message: 'All fields are required' });

  const event_code = `${event_name.replace(/\s+/g, '').toUpperCase()}_${Date.now()}`;
  const sql = 'INSERT INTO events (event_name, event_date, event_code) VALUES (?, ?, ?)';
  db.query(sql, [event_name, event_date, event_code], (err, result) => {
    if (err) return res.status(500).json({ message: err.sqlMessage });
    res.status(201).json({
      message: 'Event created successfully',
      event: { event_id: result.insertId, event_name, event_date, event_code }
    });
  });
});


// ----------------------
// CREATE STALL (Stall Management)
// ----------------------
app.post('/lecturer/stalls', (req, res) => {
  const { event_id, title, description, about, aim, scope, lesson } = req.body;
  if (!event_id || !title) {
    return res.status(400).json({ error: 'Event ID and Stall Title are required.' });
  }
  const sql = `INSERT INTO stalls (event_id, title, description, about, aim, scope, lesson) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  db.query(sql, [event_id, title, description, about, aim, scope, lesson], (err, result) => {
    if (err) return res.status(500).json({ error: err.sqlMessage });
    res.status(201).json({ message: 'Stall created successfully', stall_id: result.insertId });
  });
});

app.post('/events/:event_id/stalls', (req, res) => {
  const event_id = req.params.event_id;
  const { title, description, about, aim, scope, lesson } = req.body;

  if(!title){
    return res.status(400).json({error: 'Stall Title is required!'});
  }

  const sql = `INSERT INTO stalls (event_id, title, description, about, aim, scope, lesson) VALUES (?, ?, ?, ?, ?, ?, ?)`;
  db.query(sql, [event_id, title, description, about, aim, scope, lesson], (err, result) => {
    if (err) return res.status(500).json({ error: err.sqlMessage });
    res.status(201).json({ message: 'Stall created successfully', stall_id: result.insertId });
  });
});

// ----------------------
// GET STALLS FOR EVENT
// ----------------------
app.get('/events/:event_id/stalls', (req, res) => {
  const event_id = req.params.event_id;
  const sql = `SELECT * FROM stalls WHERE event_id = ?`;
  
  db.query(sql, [event_id], (err, results) => {
    if (err) return res.status(500).json({ error: err.sqlMessage });
    res.status(200).json(results);
  });
});

// ----------------------
// UPDATE STALL (NEW ENDPOINT)
// ----------------------
app.put('/lecturer/stalls/:stall_id', (req, res) => {
  const stall_id = req.params.stall_id;
  const { title, description, about, aim, scope, lesson } = req.body;
  
  if (!title) {
    return res.status(400).json({ error: 'Stall Title is required.' });
  }
  
  const sql = `UPDATE stalls SET title = ?, description = ?, about = ?, aim = ?, scope = ?, lesson = ? WHERE stall_id = ?`;
  db.query(sql, [title, description, about, aim, scope, lesson, stall_id], (err, result) => {
    if (err) return res.status(500).json({ error: err.sqlMessage });
    if (result.affectedRows === 0) return res.status(404).json({ error: 'Stall not found' });
    res.json({ message: 'Stall updated successfully' });
  });
});

// ----------------------
// CONFIRM ATTENDANCE
// ----------------------
app.post('/confirm_attendance', (req, res) => {
  const { student_number, event_code } = req.body;
  if (!student_number || !event_code) return res.status(400).json({ message: 'Student number and event code required' });

  const checkSql = 'SELECT * FROM attendance WHERE student_number = ? AND event_code = ?';
  db.query(checkSql, [student_number, event_code], (err, rows) => {
    if (err) return res.status(500).json({ message: err.sqlMessage });
    if (rows.length > 0) return res.json({ message: 'Attendance already confirmed' });

    const insertSql = 'INSERT INTO attendance (student_number, event_code, status) VALUES (?, ?, ?)';
    db.query(insertSql, [student_number, event_code, 'Present'], (err2) => {
      if (err2) return res.status(500).json({ message: err2.sqlMessage });
      res.json({ message: 'Attendance confirmed ✅' });
    });
  });
});

// ----------------------
// GET ATTENDANCE FOR STUDENT
// ----------------------
app.get('/attendance/:student_number', (req, res) => {
  const student_number = req.params.student_number;
  const sql = `
    SELECT e.event_name, e.event_date, e.event_code,
           IFNULL(a.status, 'Absent') AS status
    FROM events e
    LEFT JOIN attendance a ON e.event_code = a.event_code AND a.student_number = ?
    ORDER BY e.event_date DESC
  `;
  db.query(sql, [student_number], (err, results) => {
    if (err) return res.status(500).json({ message: err.sqlMessage });
    res.json(results);
  });
});

// ----------------------
// START SERVER
// ----------------------
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});

