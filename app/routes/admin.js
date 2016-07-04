var Async = require('async')
var User = require('../models/user')
var Action = require('../models/action')
var Location = require('../models/location')
var Organization = require('../models/organization')
var OrganizationType = require('../models/organizationType')
var Person = require('../models/person')
var tools = require('../tools')
var slugify = require('slug')

module.exports = function(app) {

  app.get('/admin', function(req, res) {
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
      }
    ],
    function(err, results) { 
      var data = {}
      console.log(results)
      res.render('admin/overview.pug', {
        errors: err,
        models: {
          users: results[0],
          actions: results[1],
          locations: results[2],
          organizations: results[3],
          people: results[4]
        }
      })
    })
  })

  app.get('/admin/:type', function(req, res) {
    var type = req.params.type
    if(type == 'user' || type == 'users')
      var model = User
    else
      var model = tools.getModel(type)
    model.find({}, function(err, data) {
      if(err)
        callback(err)
      res.render('admin/model.pug', {
        type: {
          s: tools.singularize(type),
          p: tools.pluralize(type)
        },
        objects: data
      })
    })
  })

  app.get('/admin/:type/new', function(req, res) {
    var type = req.params.type
    res.render('admin/edit.pug', {
      type: {
        s: tools.singularize(type),
        p: tools.pluralize(type)
      },
      action: 'create'
    })
  })

  app.post('/admin/:type/create', function(req, res) {
    var data = req.body
    var type = req.params.type
    var errors
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

  app.post('/admin/:type/quick-create', function(req, res) {
    var data = req.body
    var type = req.params.type
    var errors
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
    }
    object.save(function(err) {
      if(err) {
        return res.json(err)
      }
      return res.json(object)
    })
  })

  app.get('/admin/:type/edit/:slug', function(req, res) {
    var type = req.params.type
    var slug = req.params.slug
    var model = tools.getModel(type)
    if(!slug) {
      res.redirect('/admin/'+type+'/new')
    } else {
      model.findOne({slug: slug}, function(err, object) {
        console.log(object)
        if (err)
          throw err
        else
          res.render('admin/edit.pug', {
            object: object,
            id: object._id,
            action: 'update',
            type: {
              s: tools.singularize(type),
              p: tools.pluralize(type)
            }
          })
      })
    }
  })

  app.post('/admin/:type/update/:id', function(req, res) {
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

  app.get('/admin/:type/remove/:id', function(req, res) {
    var type = req.params.type
    var id = req.params.id
    var model = tools.getModel(type)
    model.findByIdAndRemove(id, function(err, object) {
      if (err) throw err
      console.log(type+' successfully deleted!')
      res.redirect('/admin/'+type)
    })
  })

  app.get('/admin/:type/quick-create', function(req, res) {
    var type = req.params.type
    if(!type)
      return
    res.render('admin/forms/partials/quickCreate.pug', {
      type: type
    })
  })
}