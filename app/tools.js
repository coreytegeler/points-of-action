var slug = require('slug')
var moment = require('moment')

var User = require('./models/user')
var Action = require('./models/action')
var Term = require('./models/term')
var Tactic = require('./models/tactic')
var Location = require('./models/location')
var Organization = require('./models/organization')
var OrganizationType = require('./models/organizationType')
var Person = require('./models/person')

var isLoggedIn = function(req, res, next) {
  // if(req.isAuthenticated())
  //   return next();
  // res.redirect('/admin/login');
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
var preSave = function(object) {
  if(!object.slug)
    object.slug = slug(object.name, {lower: true})
}

exports.isLoggedIn = isLoggedIn;
exports.singularize = singularize;
exports.pluralize = pluralize;
exports.getModel = getModel;
exports.preSave = preSave;