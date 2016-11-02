var Async = require('async')
var tools = require('../tools')
module.exports = function(app) {

	app.get('/api/', function(req, res) {
    var type = tools.singularize(req.query.type)
    var slug = req.query.slug
    var id = req.query.id
    var filter = req.query.filter
    var format = req.query.format
    var model = tools.getModel(type)
    if(!model)
      return res.json(null)
    query = {}
    if(filter) {
      query[filter] = id
    } else if(id) {
      query._id = id
    } else if(slug){
      query.slug = slug
    }
    model.find(query, function(err, items) {
      if(err)
        callback(err)
      res.json(items)
    })
  })

  app.get('/content/', function(req, res) {
    var type = req.query.type
    var slug = req.query.slug
    var id = req.query.id
    var filter = req.query.filter
    var format = req.query.format
    var model = tools.getModel(type)
    if(!model)
      return res.json(null)
    query = {}
    if(id) {
      query._id = id
    }
    else if(slug) {
      query.slug = slug
    } else if(filter) {
      query[filter] = id
    }
    model.find(query, function(err, object) {
      if(err)
        callback(err)
      res.render('content/'+type+'.pug', {
        type: {
          s: tools.singularize(type),
          p: tools.pluralize(type)
        },
        object: object[0]
      })
    })
  })
}