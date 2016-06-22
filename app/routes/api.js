var Async = require('async')
var Action = require('../models/action')
var Location = require('../models/location')
var Organization = require('../models/organization')
var Person = require('../models/person')
var tools = require('../tools')
module.exports = function(app) {
	app.get('/api/:type/:slug/:format', function(req, res) {
    var type = req.params.type
    var slug = req.params.slug
    var format = req.params.format
    var model = tools.getModel(type)
    
    model.find({}, function(err, items) {
      if(err)
        callback(err)
      console.log(items)
      res.json(items)
    })
  })
}