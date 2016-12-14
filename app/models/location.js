var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var locationSchema = mongoose.Schema({
	name: {
		type: String,
		require: true
	},
	slug: String,
	parentLocation: String,
	locationType: String,
	pointAddress: String,
	point: Mixed,
	subtype: {
		type: String,
		value: Mixed
	},
	images: Mixed,
	description: String,
	type: String,
	action: Mixed
}, { 
	timestamps: true
})

locationSchema.pre('save', function(next) {
	tools.preSave(this, 'location')
  next()
})

module.exports = mongoose.model('Location', locationSchema)