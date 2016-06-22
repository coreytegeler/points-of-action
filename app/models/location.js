var tools = require('../tools')
var mongoose = require('mongoose')
var slug = require('slug')

var locationSchema = mongoose.Schema({
	name: {
		type: String,
		require: true
	},
	slug: String,
	locationType: String,
	point: {
		latitude: String,
		longitude: String
	},
	startPoint: {
		latitude: String,
		longitude: String
	},
	endPoint: {
		latitude: String,
		longitude: String
	},
	subtype: {
		type: String,
		value: mongoose.Schema.Types.Mixed
	},
	description: String
}, { 
	timestamps: true
})

locationSchema.pre('save', function(next) {
	tools.preSave(this)
  next()
})

module.exports = mongoose.model('Location', locationSchema)