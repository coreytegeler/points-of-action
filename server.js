var express = require('express');
var app = express();
var path = require('path');
var port = process.env.PORT || 8080;
var mongoose = require('mongoose');
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var flash = require('connect-flash');

var morgan       = require('morgan');
var cookieParser = require('cookie-parser');
var bodyParser   = require('body-parser');
var session      = require('express-session');

var db = {
	development: 'localhost:27017/civil-rights',
	test: 'localhost:27017/civil-rights',
	production: process.env.MONGOLAB_URI
};

app.set('dbUrl', db[app.settings.env]);
mongoose.connect(app.get('dbUrl')); // connect to our database

require('./config/passport')(passport); // pass passport for configuration

var sass = require('node-sass');
var coffeeScript = require('coffee-script');
require('coffee-script').register();
app.set('port', port);
app.set('view engine', 'pug');
app.use(express.static(path.join(__dirname, 'public')));
app.locals.uppercase = function(value){
  return value.charAt(0).toUpperCase() + value.slice(1);
};

// set up our express application
app.use(morgan('dev')); // log every request to the console
app.use(cookieParser()); // read cookies (needed for auth)
app.use(bodyParser()); // get information from html forms

// required for passport
var User = require('./app/models/user');
passport.use(User.createStrategy());
passport.serializeUser(User.serializeUser());
passport.deserializeUser(User.deserializeUser());


app.use(session({ secret: 'isthissupposedtobesomethingspecialoristhisokay' })); // session secret
app.use(passport.initialize());
app.use(passport.session()); // persistent login sessions
app.use(flash()); // use connect-flash for flash messages stored in session

// routes
require('./app/routes/user.js')(app, passport);
require('./app/routes/admin.js')(app);
require('./app/routes/main.js')(app);
require('./app/routes/api.js')(app);

// launch
app.listen(port);
console.log('IT\'S GOING DOWN ON PORT ' + port);