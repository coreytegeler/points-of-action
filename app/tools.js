var User = require('./models/user')
var Action = require('./models/action')
var Term = require('./models/term')
var Tactic = require('./models/tactic')
var Location = require('./models/location')
var Organization = require('./models/organization')
var Person = require('./models/person')
var Image = require('./models/image')
var OrganizationType = require('./models/organizationType')
var PersonType = require('./models/personType')
var Async = require('async')
var slugify = require('slug')
var moment = require('moment')


var isLoggedIn = function(req, res, next) {
  // REMOVE ON PRODUCTION
  return next();
  if(req.isAuthenticated())
    return next();
  res.redirect('/admin/login');
  return next();
}

var newObj = function(model, data) {
  switch(model) {
    case 'user':
      return new User(data)
    case 'action':
      return new Action(data)
    case 'person':
      return new Person(data)
    case 'location':
      return new Location(data)
    case 'organization':
      return new Organization(data)
    case 'term':
      return new Term(data)
    case 'tactic':
      return new Tactic(data)
    case 'image':
      return new Image(data)
    case 'personType':
      return new PersonType(data)
    case 'organizationType':
      return new OrganizationType(data)
    default:
      return false
  }
}

var singularize = function(string) {
  switch(string) {
    case 'users':
      return 'user'
    case 'actions':
      return 'action'
    case 'people':
      return 'person'
    case 'locations':
      return 'location'
    case 'organizations':
      return 'organization'
    case 'terms':
      return 'term'
    case 'tactics':
      return 'tactic'
    case 'images':
      return 'image'
    case 'personTypes':
      return 'personType'
    case 'organizationTypes':
      return 'organizationType'
    default:
      return string
  }
}
var pluralize = function(string) {
  switch(string) {
    case 'user':
      return 'users'
    case 'action':
      return 'actions'
    case 'person':
      return 'people'
    case 'location':
      return 'locations'
    case 'organization':
      return 'organizations'
    case 'term':
      return 'terms'
    case 'tactic':
      return 'tactics'
    case 'image':
      return 'images'
    case 'personType':
      return 'personTypes'
    case 'organizationType':
      return 'organizationTypes'
    default:
      return string
  }
}

var getModel = function(model) {
  var model = singularize(model)
  switch(model) {
    case 'user':
      return User
    case 'action':
      return Action
    case 'person':
      return Person
    case 'location':
      return Location
    case 'organization':
      return Organization
    case 'term':
      return Term
    case 'tactic':
      return Tactic
    case 'image':
      return Image
    case 'personType':
      return PersonType
    case 'organizationType':
      return OrganizationType
  }
}

var preSave = function(object, model) {
  if(!object.model && model)
    object.model = model

  switch(object.model) {
    case 'person':
      var name = object.firstName + ' ' + object.lastName
      object.name = name
      break
    case 'action':
      console.log(object.location)
      // Location.update({_id: id}, {$set: {action: action}}, {new: true, runValidators: true}, {multi: true}, function(err, object) {
      // })
      break
    default:
      break
  }


  var parsables = ['images', 'month', 'day', 'year', 'organizations','locations', 'tactics', 'people']
  for(var i = 0; i < parsables.length; i++) {
    var name = parsables[i]
    if(typeof object[name] === 'string') {
      object[name] = JSON.parse(object[name])
    } else if(typeof object[name] === 'object') {
      for(var j = 0; j < object[name].length; j++) {
        if(typeof object[name][j] === 'string') {
          object[name][j] = JSON.parse(object[name][j])
        }
      }
    }
  }
  if(object.month || object.day || object.year) {
    object.date = {
      month: object.month,
      day: object.day,
      year: object.year
    }
  }
  if(object.name) {
    var slug = slugify(object.name, {lower: true})
    object.slug = slug
  }
  // else if(object.location) {
  //   model = getModel(object.model)
  //   model.findOneAndUpdate({_id: id}, {$set: {action: action}}, {new: true, runValidators: true}, function(err, object) {
  // }
  return object
}

exports.isLoggedIn = isLoggedIn;
exports.newObj = newObj;
exports.singularize = singularize;
exports.pluralize = pluralize;
exports.getModel = getModel;
exports.preSave = preSave;