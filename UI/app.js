const express = require('express');
const app = express();
const path = require('path');
const axios = require('axios');
const cookieParser = require('cookie-parser');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const { check, validationResult } = require('express-validator');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const expressWinston = require('express-winston');

// Load environment variables
require('dotenv').config();

// Configuration
const port = process.env.PORT || 3000;
const secretKey = process.env.SECRET_KEY || 'xco0sr0fh4e52x03g9mv';
const weatherHost = process.env.WEATHER_HOST || 'localhost';
const weatherPort = process.env.WEATHER_PORT || 5000;
const authHost = process.env.AUTH_HOST || 'localhost';
const authPort = process.env.AUTH_PORT || 8080;

// Logging setup
const logger = winston.createLogger({
    transports: [
        new winston.transports.Console(),
    ],
});

app.use('/', express.static(path.join(__dirname, 'public/static')));
app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cookieParser());

// Logging middleware
app.use(
    expressWinston.logger({
        transports: [
            new winston.transports.Console(),
            new winston.transports.File({ filename: 'requests.log' }),
        ],
        format: winston.format.combine(
            winston.format.timestamp(),
            winston.format.json()
        ),
    })
);

// Authentication middleware
function authenticateToken(req, res, next) {
    const token = req.cookies.token;
    if (!token) {
      return res.redirect('/login');
    }
  
    jwt.verify(token, secretKey, function (err, decoded) {
      if (err) {
        logger.error(err);
        return res.redirect('/login');
      }
  
      // If the token is valid, attach the decoded payload to the request object
      req.username = decoded;
      next();
    });
  }
  

// Rate limiting middleware
const limiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 100, // 100 requests per minute
});
app.use(limiter);

// Application root
app.get('/', authenticateToken, (req, res) => {
    res.sendFile(path.join(__dirname, '/public/index.html'));
});


// Health check endpoint
app.get('/health', (req, res) => {
    res.sendStatus(200);
});

// Login endpoint
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, '/public/login.html'));
});

app.post(
    '/login',
    [
        check('username').notEmpty().withMessage('Username is required'),
        check('password').notEmpty().withMessage('Password is required'),
    ],
    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const response = await axios.post(
                `http://${authHost}:${authPort}/users/${req.body.username}`,
                {
                    user_name: req.body.username,
                    user_password: req.body.password,
                }
            );
            res.cookie('token', response.data.JWT, { httpOnly: true });
            res.redirect('/');
        } catch (error) {
            logger.error(error);
            res.redirect('/login?error=invalidcreds');
        }
    }
);

// Signup endpoint
app.get('/signup', (req, res) => {
    res.sendFile(path.join(__dirname, '/public/signup.html'));
});

app.post(
    '/signup',
    [
        check('username').notEmpty().withMessage('Username is required'),
        check('password').notEmpty().withMessage('Password is required'),
    ],
    async (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }

        try {
            const response = await axios.post(
                `http://${authHost}:${authPort}/users/`,
                {
                    user_name: req.body.username,
                    user_password: req.body.password,
                }
            );
            res.redirect('/login');
        } catch (error) {
            logger.error(error);
            res.redirect('/signup?error=userexists');
        }
    }
);

// Logout endpoint
app.get('/logout', (req, res) => {
    res.clearCookie('token');
    res.redirect('/login');
});

// Weather endpoint
app.get('/weather/:city', async (req, res) => {
    try {
      const city = req.params.city;
      const response = await axios.get(`http://${process.env.WEATHER_HOST}:${process.env.WEATHER_PORT}/${city}`);
      const weatherData = response.data;
      res.setHeader('Content-Type', 'application/json'); // Set Content-Type header
      res.send(weatherData); // Send the weather data as the response
    } catch (error) {
      console.error(error);
      res.status(500).send('Internal Server Error');
    }
  });
  

// Error handling middleware
app.use((err, req, res, next) => {
    logger.error(err);
    res.status(500).send('Internal Server Error');
});

// Start the server
app.listen(port, () => {
    console.log(`Weather app listening at http://localhost:${port}`);
});

