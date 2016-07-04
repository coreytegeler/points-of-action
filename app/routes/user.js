var express = require('express');
var passport = require('passport');
var tools = require('../tools');
var User = require('../models/user');
var slugify = require('slug')

module.exports = function(app, passport) {
	app.get('/admin', function (req, res) {
		res.render('index', { user : req.user });
	});

	app.get('/admin/signup', function(req, res) {
		if(req.user)
			return res.redirect('/admin/profile')
		res.render('admin/edit.pug', {
      type: {
        s: 'user',
        p: 'users'
      },
      action: 'create'
    })
	});

	app.post('/admin/user/create', function(req, res) {
		var data = req.body
		if(data.password != data.confirmPassword) {
			console.log('Passwords do not match')
	    return res.redirect('/admin/signup')
	  }
		User.register(
			new User({
				firstName: data.firstName,
				lastName: data.lastName,
		 		email: data.email.toLowerCase(),
		 		username: data.email.toLowerCase()
			}), data.password, function(err, user) {
				if (err) {
					console.log('Error on signup', err)
					return res.render('admin/edit.pug', {
	          errors: err,
	          type: { s: 'user', p: 'users' },
	          object: user,
	          action: 'update'
	        })
				}
				console.log('User registered', user);
		 		req.logIn(user, function(err) {
		      if (err) {
		      	console.log('Error on login', err)
		      	return next(err)
		      }
		      return res.redirect('/admin/profile')
		    });
			});
	});

	app.get('/admin/login', function(req, res) {
		if(req.user)
			return res.redirect('/admin/profile')
		res.render('admin/login', {
			user: req.user,
			error: req.flash('error')
		});
	});

	app.post('/admin/login', function(req, res, next) {
	  passport.authenticate('local', function(err, user, info) {
	  	console.log('Logging in', err, user, info)
	    if (err) {
	    	console.log('Error on login (authenticate)', err)
	    	return next(err)
	    }
	    if (!user) {
	    	console.log(user + ' is not a user')
	    	return res.redirect('/admin/login')
	    }
	    req.logIn(user, function(err) {
	      if (err) {
	      	console.log('Error on login', err)
	      	return next(err)
	      }
	      return res.redirect('/admin/profile')
	    });
	  })(req, res, next)
	});

	app.get('/admin/logout', function(req, res) {
		req.logout();
    req.session.save(function (err) {
      if (err) {
        return next(err);
      }
      res.redirect('/');
    });
	});

	app.get('/admin/profile', tools.isLoggedIn, function(req, res) {
		var type = 'user'
		var user = req.user
    res.render('admin/edit.pug', {
      object: user,
      id: user._id,
      action: 'update',
      type: {
        s: tools.singularize(type),
        p: tools.pluralize(type)
      }
    })
  })

  app.post('/admin/user/update/:id', function(req, res) {
    var data = req.body
    var type = req.params.type
    var id = req.params.id
    var errors
    var model = tools.getModel(type)
    var name = data.firstName + ' ' + data.lastName
    data.name = name
    data.username = data.email
    if(data.name) {
      var slug = slugify(data.name, {lower: true})
      data.slug = slug
    }
    User.findOne({_id: id}, function(err, object) {
      if(err) {
        console.log('Error on user update', err)
        res.render('admin/edit.pug', {
          errors: err,
          type: { s: 'user', p: 'users' },
          object: object,
          action: 'update'
        })
      } else {
      	if(data.password != data.confirmPassword) {
      		console.log('Passwords do not match')
	        return res.redirect('/admin/profile')
	      }
    		object.setPassword(data.password, function(err) {
          if (err) {
          	console.log('Error on password update', err)
          	return res.redirect('/admin/profile')
          }
          object.save(function(error){
            if(err)
              console.log('Error on user update', err)
            req.session.save(function (err) {
	            if (err) {
	            	console.log('Error on user session save', err)
	              return next(err);
	            }
			        console.log('Updated user', object)
			        res.redirect('/admin/profile')
	          })
          })
        })
      }
    })
  })
}