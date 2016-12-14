var Async = require('async')
var User = require('../models/user')
var Action = require('../models/action')
var Tactic = require('../models/tactic')
var Term = require('../models/term')
var Location = require('../models/location')
var Organization = require('../models/organization')
var OrganizationType = require('../models/organizationType')
var Person = require('../models/person')
var Image = require('../models/image')

var tools = require('../tools')
var slugify = require('slug')

var path  = require('path')
var fs  = require('fs')
var multer  = require('multer')
var gm  = require('gm')

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
        Term.find({}, function(err, data) {
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
          terms: results[5],
          tactics: results[6]
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
    if(data.type === 'location') {
       tools.geocoder.geocode(data.pointAddress, function(err, location) {
          if(err) {
            console.log('Failed geocoding:')
            console.log(err)
          } else {
            console.log('Geocoded address:')
            console.log(location)
            var locationType = data.locationType
            data[locationType] = location[0]
          }
          createObj(type, data, res, false)
        })
    } else {
      createObj(type, data, res, false)
    }
  })

  var createObj = function(type, data, res, quicky) {
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
      case 'organizationType':
        var object = new OrganizationType(data)
        break
      case 'term':
        var object = new Term(data)
        break
      case 'tactic':
        var object = new Tactic(data)
        break
      default:
        return false
    }
    object.type = type
    object.save(function(err) {
      if(err) {
        console.log('Failed: '+err)
        res.render('admin/edit.pug', {
          errors: err,
          type: {
            s: tools.singularize(object.type),
            p: tools.pluralize(object.type)
          },
          action: 'create',
          object: data
        })
        return false
      } else {
        console.log('Created: '+object)
        if(quicky) {
          res.json(object)
        } else {
          res.redirect('/admin/'+type+'/edit/'+object.slug)
        }
      }
    })
  }

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
        if(!object)
          return res.redirect('/admin/'+type+'/new')
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
    data = tools.preSave(data, type)
    if(type === 'location') {
      tools.geocoder.geocode(data.pointAddress, function(err, location) {
        if(err) {
          console.log('Failed geocoding:')
          console.log(err)
        } else {
          console.log('Geocoded address:')
          console.log(location)
          var locationType = data.locationType
          data[locationType] = location[0]
        }
        updateObj(type, id, data, res)
      })
    } else {
      updateObj(type, id, data, res)
    }

  })

  var updateObj = function(type, id, data, res) {
    var model = tools.getModel(type)
    model.findOneAndUpdate({_id: id}, data, {new: true, runValidators: true, safe: true, upsert: true}, function(err, object) {
      if(err) {
        console.log('Failed:'+err)
        if(res) {
          res.render('admin/edit.pug', {
            errors: err,
            type: {
              s: tools.singularize(type),
              p: tools.pluralize(type)
            },
            object: data,
            action: 'update'
          })
        }
      } else {
        console.log('Updated:'+object)
        if(res) {
          res.redirect('/admin/'+type+'/edit/'+object.slug)
        }
      }
    })
  }

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

  app.get('/admin/:type/quicky', tools.isLoggedIn, function(req, res) {
    var type = req.params.type
    if(!type)
      return
    var form = 'quicky'
    if(type == 'image')
      form = 'image'
    if(form)
      res.render('admin/'+form+'.pug', {
        type: type
      })
    else
      return
  })

  app.post('/admin/:type/quicky', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var type = tools.singularize(req.params.type)
    var errors    
    switch(type) {
      case 'neighborhood':
        var object = new Neighborhood(data)
        break
      case 'tour':
        var object = new Tour(data)
        break
      case 'style':
        var object = new Style(data)
        break
      case 'use':
        var object = new Use(data)
        break
      case 'material':
        var object = new Material(data)
        break
      case 'structure':
        var object = new Structure(data)
        break
      case 'roofType':
        var object = new RoofType(data)
        break
      case 'roofMaterial':
        var object = new RoofMaterial(data)
        break
      case 'threat':
        var object = new Threat(data)
        break
      case 'environment':
        var object = new Environment(data)
        break
      default:
        return
    }
    object.save(function(err) {
      if(!err) {
        console.log('Created:')
        console.log(object)
        return res.json(object)
      } else {
        console.log('Failed:')
        console.log(err)
        return res.json(err)
      }
    })
  })

  app.get('/admin/image/quicky/:id', tools.isLoggedIn, function(req, res) {
    var id = req.params.id
    Image.findById(id, function(err, image) {
      console.log(image)
      res.render('admin/image.pug', {
        object: image,
        type: 'image'
      })
    })
  })

  var storage = multer.diskStorage({
    destination: function (req, file, callback) {
      callback(null, appRoot+'/public/uploads/')
    },
    filename: function (req, file, callback) {
      var datetimestamp = Date.now();
      callback(null, file.fieldname + '-' + datetimestamp + '.' + file.originalname.split('.')[file.originalname.split('.').length -1])
    }
  })

  var upload = multer({
    storage: storage
  }).single('image')

  app.post('/admin/image/quicky/', tools.isLoggedIn, function(req, res) {
    var data = req.body

    upload(req, res, function(err) {
      if(err) {
        console.log('Failed image upload:', err)
        return res.json(err)
      }

      var imageData = req.file
      var filename = imageData.filename
      data.filename = filename
      data.original = '/uploads/'+filename
      data.medium = '/uploads/medium/'+filename
      data.small = '/uploads/small/'+filename

      gm(appRoot+'/public'+data.original).resize(800, 800).quality(100).autoOrient().write(appRoot+'/public/'+data.medium, function (err) {
        if(err) {
          console.log('Failed medium resize:', err)
          return res.json(err)
        } else {
          console.log('Medium resize:', this)
        }
      })

      gm(appRoot+'/public'+data.original).resize(250, 250).quality(100).autoOrient().write(appRoot+'/public/'+data.small, function (err) {
        if(err) {
          console.log('Failed small resize:', err)
          return res.json(err)
        } else {
          console.log('Small resize:', this)
        }
      })

      var image = new Image(data)
      image.save(function(err) {
        if(!err) {
          console.log('Added:')
          console.log(image)
          return res.json(image)
        } else {
          console.log(err)
          return res.json(err)
        }
      })
    })
  })

  app.post('/admin/image/quicky/:id', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var id = req.params.id
    Image.findOneAndUpdate({_id: id}, data, {new: true, runValidators: true}, function(err, image) {
       if(!err) {
        console.log('Updated:')
        console.log(image)
        res.json(image)
      } else {
        console.log('Failed:')
        console.log(err)
        return res.json(err)
      }
    })
  })
}