var User = require('../models/user')
var tools = require('../tools')
module.exports = function(app, passport) {

  app.get('/signup', function(req, res) {
    res.redirect('/admin/signup')
  })

  app.get('/admin/signup', function(req, res) {
    res.render('admin/signup.pug', {
      message: req.flash('signupMessage')
    })
  })

  app.post('/admin/signup', passport.authenticate('local-signup', {
    successRedirect: '/admin/profile',
    failureRedirect: '/admin/signup',
    failureFlash: true
  }))

  app.get('/login', function(req, res) {
    res.redirect('/admin/login')
  })

  app.get('/admin/login', function(req, res) {
    res.render('admin/login.pug', {
      message: req.flash('loginMessage')
    }) 
  })

  app.post('/admin/login', passport.authenticate('local-login', {
    successRedirect: '/admin',
    failureRedirect: '/admin/login',
    failureFlash: true
  }))

  app.get('/admin/profile', tools.isLoggedIn, function(req, res) {
    res.render('admin/profile.pug', {
      user : req.user
    });
  });

  app.get('/admin/logout', function(req, res) {
    req.logout()
    res.redirect('/')
  })
  
}
