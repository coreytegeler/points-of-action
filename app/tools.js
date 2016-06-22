var User = require('./models/user')
var Action = require('./models/action')
var Location = require('./models/location')
var Organization = require('./models/organization')
var Person = require('./models/person')
var slug = require('slug')

var isLoggedIn = function(req, res, next) {
  if (req.isAuthenticated())
    return next();
  res.redirect('/admin');
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
    default:
      return string
  }
}
var getModel = function(type) {
  var type = pluralize(type)
  switch(type) {
    case 'users':
      return User
    case 'actions':
      return Action
    case 'people':
      return Person
    case 'locations':
      return Location
    case 'organizations':
      return Organization
  }
}
var preSave = function(item) {
  if(!item.slug)
    item.slug = slug(item.name, {lower: true})
}
exports.isLoggedIn = isLoggedIn;
exports.singularize = singularize;
exports.pluralize = pluralize;
exports.getModel = getModel;
exports.preSave = preSave;