const express = require('express');
const path = require('path');
const session = require('express-session');
const bcrypt = require('bcrypt');
const pool = require('./models/db');
require('dotenv').config();

const app = express();

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '/public')));

app.use(session({
    secret: 'your-secret-key',
    resave: false,
    saveUninitialized: false,
}));
app.post('/login', async (req, res) => {
    const { username, password } = req.body;

    try {
        const [rows] = await pool.query('SELECT * FROM Users WHERE username = ?', [username]);

        if (rows.length === 0) {
            return res.status(401).send('User not found');
        }

        const user = rows[0];
        const match = await bcrypt.compare(password, user.password_hash);

        if (!match) {
            return res.status(401).send('Incorrect password');
        }

        req.session.user = {
            id: user.user_id,
            username: user.username,
            role: user.role
        };

        if (user.role === 'owner') {
            res.redirect('/owner-dashboard.html');
        } else if (user.role === 'walker') {
            res.redirect('/walker-dashboard.html');
        } else {
            res.send('Unknown role');
        }

    } catch (err) {
        console.error(err);
        res.status(500).send('Server error');
    }
});

const walkRoutes = require('./routes/walkRoutes');
const userRoutes = require('./routes/userRoutes');
app.use('/api/walks', walkRoutes);
app.use('/api/users', userRoutes);

module.exports = app;
