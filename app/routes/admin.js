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
var sharp  = require('sharp')
var NodeGeocoder = require('node-geocoder');
var geocoder = NodeGeocoder({
  provider: 'google',
  httpAdapter: 'https',
  apiKey: 'AIzaSyAiUymfFCUE4O6kqMu-sXx9IKkMkvjYubo',
  formatter: null
})

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
        user: req.user,
        root: appRoot
      })
    })
  })

  app.get('/admin/:model', tools.isLoggedIn, function(req, res) {
    var model = req.params.model
    if(model == 'user' || model == 'users')
      var modelObj = User
    else
      var modelObj = tools.getModel(model)
    modelObj.find({}, function(err, objects) {
      if(err)
        callback(err)
      res.render('admin/model.pug', {
        model: {
          s: tools.singularize(model),
          p: tools.pluralize(model)
        },
        objects: objects,
        user: req.user,
        root: appRoot
      })
    })
  })

  app.get('/admin/:model/new', tools.isLoggedIn, function(req, res) {
    var model = req.params.model
    res.render('admin/edit.pug', {
      model: {
        s: tools.singularize(model),
        p: tools.pluralize(model)
      },
      action: 'create',
      user: req.user,
      root: appRoot
    })
  })

  app.post('/admin/:model/create', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var model = req.params.model
    var errors
    data.model = tools.singularize(model)
    if(data.model === 'location') {
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
          createObj(model, data, res, false)
        })
    } else {
      createObj(model, data, res, false)
    }
  })

  var createObj = function(model, data, res, quicky) {
    model = tools.singularize(model)
    switch(model) {
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
    object.model = model
    if(object.images) { object.images = JSON.parse(object.images) }
    object.save(function(err) {
      if(err) {
        console.log('Failed: '+err)
        res.render('admin/edit.pug', {
          errors: err,
          model: {
            s: tools.singularize(object.model),
            p: tools.pluralize(object.model)
          },
          action: 'create',
          object: object,
          root: appRoot
        })
        return false
      } else {
        console.log('Created: '+object)
        if(quicky) {
          res.json(object)
        } else {
          res.redirect('/admin/'+model+'/edit/'+object.slug)
        }
      }
    })
  }

  app.get('/admin/:model/edit/:slug', tools.isLoggedIn, function(req, res) {
    var model = req.params.model
    var slug = req.params.slug
    var modelObj = tools.getModel(model)
    if(!slug) {
      res.redirect('/admin/'+model+'/new')
    } else {
      modelObj.findOne({slug: slug}, function(err, object) {
        if (err)
          throw err
        if(!object)
          return res.redirect('/admin/'+model+'/new')
        var data = {
          object: object,
          id: object._id,
          action: 'update',
          model: {
            s: tools.singularize(model),
            p: tools.pluralize(model)
          },
          user: req.user
        }
        res.render('admin/edit.pug', data)
      })
    }
  })

  app.post('/admin/:model/update/:id', tools.isLoggedIn, function(req, res) {
    var data = req.body
    var model = req.params.model
    var id = req.params.id
    var errors
    if(model === 'location') {
      geocoder.geocode(data.pointAddress, function(err, location) {
        if(err) {
          console.log('Failed geocoding:')
          console.log(err)
        } else {
          console.log('Geocoded address:')
          console.log(location)
          var locationType = data.locationType
          data[locationType] = location[0]
        }
        updateObj(model, id, data, res)
      })
    } else {
      updateObj(model, id, data, res)
    }

  })

  var updateObj = function(model, id, data, res) {
    var modelObj = tools.getModel(model)
    data = tools.preSave(data, model)
    modelObj.findOneAndUpdate({_id: id}, data, {new: true, runValidators: true, safe: true, upsert: true}, function(err, object) {
      if(err) {
        console.log('Failed:'+err)
        if(res) {
          res.render('admin/edit.pug', {
            errors: err,
            model: {
              s: tools.singularize(model),
              p: tools.pluralize(model)
            },
            object: object,
            action: 'update',
            root: appRoot
          })
        }
      } else {
        // console.log('Updated:'+object)
        if(res) {
          res.redirect('/admin/'+model+'/edit/'+object.slug)
        }
      }
    })
  }

  app.get('/admin/:model/remove/:id', tools.isLoggedIn, function(req, res) {
    var model = tools.singularize(req.params.model)
    var id = req.params.id
    var modelObj = tools.getModel(model)
    modelObj.findByIdAndRemove(id, function(err, object) {
      if (err) throw err
      console.log(model+' successfully deleted!')
      res.redirect('/admin/'+model)
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

  app.get('/admin/:model/quicky', tools.isLoggedIn, function(req, res) {
    var model = req.params.model
    if(!model)
      return
    var form = 'quicky'
    if(form)
      res.render('admin/'+form+'.pug', {
         model: {
          s: tools.singularize(model),
          p: tools.pluralize(model)
        },
        action: 'create',
        root: appRoot
      })
    else
      return
  })

  app.post('/admin/:model/quicky/create', tools.isLoggedIn, function(req, res) {
    var model = tools.singularize(req.params.model)
    if(model == 'image') {
      createImage(req, res)
    } else {
      var data = req.body
      var object = tools.newObj(model, data)
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
    }
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

  app.get('/admin/:model/quicky/:id', tools.isLoggedIn, function(req, res) {
    var id = req.params.id
    var model = req.params.model
    var modelObj = tools.getModel(model)
    modelObj.findById(id, function(err, object) {
      res.render('admin/quicky.pug', {
        object: object,
        model: {
          s: tools.singularize(model),
          p: tools.pluralize(model)
        },
        root: appRoot
      })
    })
  })
}

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

var createImage = function(req, res) {
  var data = req.body
  upload(req, res, function(err) {
    var imageData = req.file
    if(err) {
      console.log('Failed image upload:', err)
      return res.json(err)
    } else if(!imageData) {
      console.log('No image data')
      return res.status(500).send('No image data')
    }
    var filename = imageData.filename
    if(!data.slug)
      data.slug = slugify(filename, {lower: true})
    data.filename = filename
    data.original = '/uploads/'+filename
    data.small = '/uploads/small/'+filename
    data.medium = '/uploads/medium/'+filename
    Async.parallel([
      function(callback) {
        sharp(appRoot+'/public'+data.original)
          .resize(600, 600).max().png()
          .toFile(appRoot+'/public'+data.small, function(err, image) {
            if(err) {
              console.log('Error on small image', err)
              callback(err)
            }
            console.log('small', image)
            callback(null, image)
          })
      }, function(callback) {
        sharp(appRoot+'/public'+data.original)
          .resize(1400, 1400).max().png()
          .toFile(appRoot+'/public'+data.medium, function(err, image) {
            if(err) {
              console.log('Error on medium image', err)
              callback(err)
            }
            console.log('medium', image)
            callback(null, image)
          })
      }
    ], function(err, images) {
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
}