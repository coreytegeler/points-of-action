var Async = require('async')
var tools = require('../tools')
module.exports = function(app) {

	app.get('/api/json/', function(req, res) {
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
        return res.json(err)
      res.json(items)
    })
  })

  app.get('/api/html/', function(req, res) {
    var type = req.query.type
    var slug = req.query.slug
    var id = req.query.id
    var filter = req.query.filter
    var model = tools.getModel(type)
    if(!model)
      return res.json(null)
    query = {}

    if(filter) {
      query[filter] = id
    } else if(id) {
      query._id = id
    }
    else if(slug) {
      query.slug = slug
    }
    model.find(query, function(err, object) {
      if(err)
        return res.json(err)
      res.render('content/'+type+'.pug', {
        type: {
          s: tools.singularize(type),
          p: tools.pluralize(type)
        },
        object: object
      })
    })
  })

  // var getLocation = function() {
  //   Async.waterfall([
  //     function(callback) {
  //     Async.parallel([
  //       function(callback) {
  //         Location.findOne(id, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       },
  //       function(callback) {
  //         Action.find({b: {
  //           $in: arr.map(mongoose.Types.ObjectId }
  //         }, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       },
  //       function(callback) {
  //         Organization.find({}, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       },
  //       function(callback) {
  //         Person.find({}, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       },
  //       function(callback) {
  //         Term.find({}, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       },
  //       function(callback) {
  //         Tactic.find({}, function(err, data) {
  //           if(err)
  //             callback(err)
  //           callback(null, data)
  //         })
  //       }
  //     ],
  //   ],
  //   function(err, results) { 
  //     if(err)
  //       callback(err)
  //     res.render('content/'+type+'.pug', {
  //       type: {
  //         s: tools.singularize(type),
  //         p: tools.pluralize(type)
  //       },
  //       location: object[0]
  //     })

  //     res.render('admin/index.pug', {
  //       errors: err,
  //       models: {
  //         users: results[0],
  //         actions: results[1],
  //         locations: results[2],
  //         organizations: results[3],
  //         people: results[4],
  //         terms: results[5],
  //         tactics: results[6]
  //       },
  //       user: req.user
  //     })
  //   })
  // }
}