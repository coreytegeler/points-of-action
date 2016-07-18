var Async = require('async')
var tools = require('../tools')
module.exports = function(app) {
	app.get('/api/:type/:slug/:format', function(req, res) {
    var type = req.params.type
    var slug = req.params.slug
    var format = req.params.format
    var model = tools.getModel(type)
    if(!model)
      return res.json(null)
    model.find({}, function(err, items) {
      if(err)
        callback(err)
      res.json(items)
    })
  })
}