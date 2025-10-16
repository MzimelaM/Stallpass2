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
app.post('/signup', async (req, res) => {
  const { full_name, student_number, email, password } = req.body;

  if (!full_name || !student_number || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const query = 'INSERT INTO students (student_number, full_name, email, password) VALUES (?, ?, ?, ?)';
    db.query(query, [student_number, full_name, email, hashedPassword], (err) => {
      if (err) {
        if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ message: 'Student already exists' });
        return res.status(500).json({ message: 'Database insert failed', error: err.sqlMessage });
      }
      res.status(201).json({ message: 'Student registered successfully' });
    });
  } catch (err) {
    res.status(500).json({ message: 'Password hashing failed' });
  }
});

// ----------------------
// USER LOGIN
// ----------------------
app.post('/login', (req, res) => {
  const student_number = req.body.student_number?.trim();
  const password = req.body.password?.trim();

  if (!student_number || !password) {
    return res.status(400).json({ message: 'Student number and password required' });
  }

  const query = 'SELECT student_number, full_name, email, password FROM students WHERE student_number = ? LIMIT 1';

  db.query(query, [student_number], async (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(401).json({ message: 'Invalid student number or password' });

    const user = results[0];

    console.log('Stored hash for', student_number, ':', user.password);

    const match = await bcrypt.compare(password, user.password);
    console.log('Password match:', match);

    if (!match) return res.status(401).json({ message: 'Invalid student number or password' });

    res.json({
      message: 'Login successful',
      student: {
        student_number: user.student_number,
        full_name: user.full_name,
        email: user.email,
      },
    });
  });
});

// ----------------------
// GET USER BY STUDENT NUMBER
// ----------------------
app.get('/user/:student_number', (req, res) => {
  const student_number = req.params.student_number;
  const query = 'SELECT student_number, full_name, email FROM students WHERE student_number = ? LIMIT 1';
  db.query(query, [student_number], (err, results) => {
    if (err) return res.status(500).json({ message: 'Database query failed', error: err.sqlMessage });
    if (results.length === 0) return res.status(404).json({ message: 'Student not found' });
    res.json(results[0]);
  });
}); // ✅ fixed: added missing closing brace

// ----------------------
// UPDATE USER
// ----------------------
app.put('/user/:student_number', async (req, res) => {
  const student_number = req.params.student_number;
  const { full_name, email, password } = req.body;

  if (!full_name || !email || !password) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const query = 'UPDATE students SET full_name = ?, email = ?, password = ? WHERE student_number = ?';
    db.query(query, [full_name, email, hashedPassword, student_number], (err, result) => {
      if (err) return res.status(500).json({ message: 'Update failed', error: err.sqlMessage });
      if (result.affectedRows === 0) return res.status(404).json({ message: 'Student not found' });
      res.json({ message: 'Profile updated successfully' });
    });
  } catch (err) {
    res.status(500).json({ message: 'Password hashing failed' });
  }
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
// GET LECTURER
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

// ----------------------
// UPDATE LECTURER
// ----------------------
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
// GET EVENTS
// ----------------------
app.get('/get_events', (req, res) => {
    const query = `
      SELECT event_id, event_name, event_code, event_date
      FROM events
      ORDER BY event_date DESC
    `;


    db.query(query, (err, results) => {
        if (err) {
            console.error("Error fetching events:", err);
            return res.status(500).json({ error: err.message });
        }
        res.json(results); // send the results once
    });
});

// ----------------------
// CREATE EVENT
// ----------------------
app.post('/create_event', (req, res) => {
  const { event_name, event_date, event_description } = req.body;
  if (!event_name || !event_date) return res.status(400).json({ message: 'Event name and date are required' });

  const event_code = event_name.replace(/\s+/g, '').toUpperCase() + '_' + Date.now();

  const sql = 'INSERT INTO events (event_name, event_date, event_code, event_description) VALUES (?, ?, ?, ?)';
  db.query(sql, [event_name, event_date, event_code, event_description || ''], (err, result) => {
    if (err) return res.status(500).json({ message: err.sqlMessage });
    res.status(201).json({
      message: 'Event created successfully',
      event: { event_id: result.insertId, event_name, event_date, event_code, event_description }
    });
  });
});

// ----------------------
// GET ATTENDANCE FOR A STUDENT
// ----------------------
app.get('/attendance/:studentNumber', (req, res) => {
  const studentNumber = req.params.studentNumber;

  const sql = `
    SELECT
      e.event_name,
      e.event_code,
      e.event_date,
      COALESCE(a.status, 'Absent') AS status
    FROM events e
    LEFT JOIN attendance a
      ON e.event_code = a.event_code
      AND a.student_number = ?
    ORDER BY e.event_date DESC
  `;

  db.query(sql, [studentNumber], (err, results) => {
    if (err) {
      console.error("Error fetching attendance:", err);
      return res.status(500).json({ message: "Database query failed", error: err.sqlMessage });
    }
    res.json(results);
  });
});

// ----------------------
// CONFIRM ATTENDANCE (QR SCAN)
// ----------------------
app.post('/attendance/confirm', (req, res) => {
  const { student_number, event_code } = req.body;

  if (!student_number || !event_code) {
    return res.status(400).json({ message: "Missing student_number or event_code" });
  }

  const sql = `
    INSERT INTO attendance (student_number, event_code, status, created_at)
    VALUES (?, ?, 'Present', NOW())
    ON DUPLICATE KEY UPDATE status = 'Present', created_at = NOW()
  `;

  db.query(sql, [student_number, event_code], (err) => {
    if (err) {
      console.error("Error confirming attendance:", err);
      return res.status(500).json({ message: "Failed to confirm attendance", error: err.sqlMessage });
    }

    res.json({ message: "Attendance confirmed successfully" });
  });
});


// ----------------------
// PRE-CONFIRM ATTENDANCE
// ----------------------
app.post('/attendance/preconfirm', (req, res) => {
  const { student_number, event_code } = req.body;

  if (!student_number || !event_code) {
    return res.status(400).json({ message: "Missing student_number or event_code" });
  }

  const sql = `
    INSERT INTO attendance (student_number, event_code, status, created_at)
    VALUES (?, ?, 'Expected', NOW())
    ON DUPLICATE KEY UPDATE status = 'Expected'
  `;

  db.query(sql, [student_number, event_code], (err) => {
    if (err) {
      console.error("Error pre-confirming attendance:", err);
      return res.status(500).json({ message: "Failed to pre-confirm attendance", error: err.sqlMessage });
    }

    res.json({ message: "Attendance pre-confirmed successfully" });
  });
});
// ----------------------
// WILL NOT ATTEND (or update attendance status)
// ----------------------
app.post('/attendance/update_status', (req, res) => {
  const { student_number, event_code, status } = req.body;

  if (!student_number || !event_code || !status) {
    return res.status(400).json({ message: "Missing student_number, event_code, or status" });
  }

  const sql = `
    INSERT INTO attendance (student_number, event_code, status, created_at)
    VALUES (?, ?, ?, NOW())
    ON DUPLICATE KEY UPDATE status = VALUES(status), created_at = NOW()
  `;

  db.query(sql, [student_number, event_code, status], (err) => {
    if (err) {
      console.error("Error updating attendance status:", err);
      return res.status(500).json({ message: "Failed to update attendance", error: err.sqlMessage });
    }

    // ✅ No escape needed here
    res.json({ message: `Attendance status updated: ${status}` });
  });
});


// ----------------------
// UPDATE EVENT DESCRIPTION
// ----------------------
app.put('/events/:id/description', (req, res) => {
  const { id } = req.params;
  const { event_description } = req.body;

  if (!event_description || event_description.trim() === "") {
    return res.status(400).json({ error: "Event description is required" });
  }

  const sql = "UPDATE events SET event_description = ? WHERE event_id = ?";
  db.query(sql, [event_description, id], (err, result) => {
    if (err) return res.status(500).json({ error: err.sqlMessage });
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Event not found" });
    }
    res.json({ message: "Event description updated successfully" });
  });
});
// ----------------------
// START SERVER
// ----------------------
app.listen(PORT, "0.0.0.0", () => {
  console.log('🚀 Server running on http://localhost:' + PORT);
});


