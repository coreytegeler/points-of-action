var Async = require('async')
var User = require('../models/user')
var Action = require('../models/action')
var Tactic = require('../models/tactic')
var Term = require('../models/term')
var Location = require('../models/location')
var Organization = require('../models/organization')
var OrganizationType = require('../models/organizationType')
var Person = require('../models/person')
var tools = require('../tools')
var slugify = require('slug')

module.exports = function(app) {

  app.get('/admin', tools.isLoggedIn, function(req, res) {
    Async.parallel([
      function(callback) {
        User.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Action.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Location.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Organization.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Person.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Tactic.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      },
      function(callback) {
        Term.find({}, function(err, data) {
          if(err)
            callback(err)
          callback(null, data)
        })
      }
    ],
    function(err, results) { 
      res.render('admin/index.pug', {
        errors: err,
        models: {
          users: results[0],
          actions: results[1],
          locations: results[2],
          organizations: results[3],
          people: results[4],
          terms: results[5].concat(results[6])
        },
        user: req.user
      })
    })
  })

  app.get('/admin/:type', tools.isLoggedIn, function(req, res) {
    var type = req.params.type
    if(type == 'user' || type == 'users')
      var model = User
    else
      var model = tools.getModel(type)
    model.find({}, function(err, objects) {
      if(err)
        callback(err)
      res.render('admin/model.pug', {
        type: {
          s: tools.singularize(type),
          p: tools.pluralize(type)
        },
        objects: objects,
        user: req.user
      })
    })
  })

  app.get('/admin/:type/new', tools.isLoggedIn, function(req, res) {
    var type = req.params.type
    res.render('admin/edit.pug', {
      type: {
        s: tools.singularize(type),
        p: tools.pluralize(type)
      },
      action: 'create',
        user: req.user
    })
  })

  app.post('/admin/:type/create', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var type = req.params.type
    var errors
    data.type = tools.singularize(type)
    switch(type) {
      case 'user':
        var object = new User(data)
        break
      case 'action':
        var object = new Action(data)
        break
      case 'person':
        var object = new Person(data)
        break
      case 'location':
        var object = new Location(data)
        break
      case 'organization':
        var object = new Organization(data) 
        break
      case 'tactic':
        var object = new Tactic(data) 
        break
      case 'term':
        var object = new Term(data) 
        break
    }
    object.save(function(err) {
      if(err) {
        console.log('Failed:')
        console.log(err)
        res.render('admin/edit.pug', {
          errors: err,
          type: {
            s: tools.singularize(type),
            p: tools.pluralize(type)
          },
          action: 'create'
        })
      } else {
        console.log('Updated:')
        console.log(object)
        res.redirect('/admin/'+type)
      }
    })
  })

  app.get('/admin/:type/edit/:slug', tools.isLoggedIn, function(req, res) {
    var type = req.params.type
    var slug = req.params.slug
    var model = tools.getModel(type)
    if(!slug) {
      res.redirect('/admin/'+type+'/new')
    } else {
      model.findOne({slug: slug}, function(err, object) {
        if (err)
          throw err
        var data = {
          object: object,
          id: object._id,
          action: 'update',
          type: {
            s: tools.singularize(type),
            p: tools.pluralize(type)
          },
          user: req.user
        }
        res.render('admin/edit.pug', data)
      })
    }
  })

  app.post('/admin/:type/update/:id', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var type = req.params.type
    var id = req.params.id
    var errors
    var model = tools.getModel(type)
    if(type==='person') {
      var name = data.firstName + ' ' + data.lastName
      data.name = name
    }
    if(data.name) {
      var slug = slugify(data.name, {lower: true})
      data.slug = slug
    }
    data.type = tools.singularize(type)
    model.findOneAndUpdate({_id: id}, data, {runValidators: true}, function(err, object) {
      if(err) {
        console.log('Failed:')
        console.log(err)
        res.render('admin/edit.pug', {
          errors: err,
          type: {
            s: tools.singularize(type),
            p: tools.pluralize(type)
          },
          object: object,
          action: 'update'
        })
      } else {
        console.log('Updated:')
        console.log(object)
        res.redirect('/admin/'+type+'/edit/'+object.slug)
      }
    })
  })

  app.get('/admin/:type/remove/:id', tools.isLoggedIn, function(req, res) {
    var type = tools.singularize(req.params.type)
    var id = req.params.id
    var model = tools.getModel(type)
    model.findByIdAndRemove(id, function(err, object) {
      if (err) throw err
      console.log(type+' successfully deleted!')
      res.redirect('/admin/'+type)
    })
  })

  app.get('/admin/:type/quick-create', tools.isLoggedIn, function(req, res) {
    var type = req.params.type
    if(!type)
      return
    res.render('admin/forms/partials/quickCreate.pug', {
      type: type
    })
  })

  app.post('/admin/:type/quick-create', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var type = tools.singularize(req.params.type)
    var errors
    data.type = tools.singularize(type)
    switch(type) {
      case 'user':
        var object = new User(data)
        break
      case 'action':
        var object = new Action(data)
        break
      case 'tactic':
        var object = new Tactic(data) 
        break 
      case 'person':
        var object = new Person(data)
        break
      case 'location':
        var object = new Location(data)
        break
      case 'organization':
        var object = new Organization(data) 
        break  
      case 'organizationType':
        var object = new OrganizationType(data) 
        break
    }
    object.save(function(err) {
      if(err) {
        return res.json(err)
      }
      console.log(object)
      return res.json(object)
    })
  })

}