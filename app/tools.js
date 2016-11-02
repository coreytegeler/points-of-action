var User = require('./models/user')
var Action = require('./models/action')
var Term = require('./models/term')
var Tactic = require('./models/tactic')
var Location = require('./models/location')
var Organization = require('./models/organization')
var OrganizationType = require('./models/organizationType')
var Person = require('./models/person')

var slugify = require('slug')
var moment = require('moment')
var NodeGeocoder = require('node-geocoder');
var geocoder = NodeGeocoder({
  provider: 'google',
  httpAdapter: 'https',
  apiKey: 'AIzaSyAiUymfFCUE4O6kqMu-sXx9IKkMkvjYubo',
  formatter: null
})

var isLoggedIn = function(req, res, next) {
  return next();
  if(req.isAuthenticated())
    return next();
  res.redirect('/admin/login');
  return next();
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
    case 'organizationTypes':
      return 'organizationType'
    case 'terms':
      return 'term'
    case 'tactics':
      return 'tactic'
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
    case 'organizationType':
      return 'organizationTypes'
    case 'term':
      return 'terms'
    case 'tactic':
      return 'tactics'
    default:
      return string
  }
}

var getModel = function(type) {
  var type = singularize(type)
  switch(type) {
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
    case 'organizationType':
      return OrganizationType
    case 'term':
      return Term
    case 'tactic':
      return Tactic
  }
}

var newModel = function(type, data) {
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
  }
  object.type = type
  return object
}

var preSave = function(object) {
  if(object.type === 'person') {
    var name = object.firstName + ' ' + object.lastName
    object.name = name
  } 
  // else if(object.location) {
  //   model = getModel(object.type)
  //   model.findOneAndUpdate({_id: id}, {$set: {action: action}}, {new: true, runValidators: true}, function(err, object) {
  // }
  if(object.name) {
    var slug = slugify(object.name, {lower: true})
    object.slug = slug
  }
  return object
}

exports.isLoggedIn = isLoggedIn;
exports.singularize = singularize;
exports.pluralize = pluralize;
exports.getModel = getModel;
exports.newModel = newModel;
exports.preSave = preSave;
exports.geocoder = geocoder;