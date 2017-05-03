var tools = require('../tools');

module.exports = function(app) {

  app.get('/', function(req, res, next) {
    res.render('index.pug', {
  		user: req.user,
      root: appRoot
    })
  })

  app.get('/:model/:slug', function(req, res, next) {
  	var model = req.params.model
  	var slug = req.params.slug
    var modelObj = tools.getModel(model)
    if(!modelObj)
      return next()
    modelObj.findOne({slug: slug}, function(err, object) {
      if(err)
        callback(err)
      res.render('index.pug', {
        id: object.id,
        title: object.title,
        slug: object.slug,
        model: {
          s: tools.singularize(model),
          p: tools.pluralize(model)
        },
    		user: req.user,
        root: appRoot
      })
    })
  })

}