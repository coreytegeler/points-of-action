var slug = require('slug')
var moment = require('moment')

var User = require('./models/user')
var Action = require('./models/action')
var Tactic = require('./models/tactic')
var Location = require('./models/location')
var Organization = require('./models/organization')
var OrganizationType = require('./models/organizationType')
var Person = require('./models/person')

var isLoggedIn = function(req, res, next) {
  if(req.isAuthenticated())
    return next();
  res.redirect('/admin/login');
}
var singularize = function(string) {
  switch(string) {
    case 'users':
      return 'user'
    case 'actions':
      return 'action'
    case 'tactics':
      return 'tactic'
    case 'people':
      return 'person'
    case 'locations':
      return 'location'
    case 'organizations':
      return 'organization'
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
    case 'tactic':
      return 'tactics'
    case 'person':
      return 'people'
    case 'location':
      return 'locations'
    case 'organization':
      return 'organizations'
    case 'organizationType':
      return 'organizationTypes'
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
    case 'tactic':
      return Tactic
    case 'person':
      return Person
    case 'location':
      return Location
    case 'organization':
      return Organization
    case 'organizationType':
      return OrganizationType
  }
}
var preSave = function(item) {
  if(!item.slug)
    item.slug = slug(item.name, {lower: true})
}

var getMonths = function() {
  var months = []
  for (var i = 0; i < 12; i++) {
   months[i] = moment.months(i)
  }
  return months
}
var getDays = function() {
  var days = []
  for (var i = 0; i < 12; i++) {
    days[i] = moment(i+1, 'M').daysInMonth()
  }
  return days
}
var getYears = function() {
  var years = {
    'min': '1900',
    'max': moment().year()
  }
  return years
}

exports.isLoggedIn = isLoggedIn;
exports.singularize = singularize;
exports.pluralize = pluralize;
exports.getModel = getModel;
exports.preSave = preSave;
exports.getMonths = getMonths;
exports.getDays = getDays;
exports.getYears = getYears;