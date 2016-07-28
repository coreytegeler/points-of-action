var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var organizationSchema = mongoose.Schema({
	name: String,
	slug: String,
	organizationType: {
		type: Mixed
	},
	location: Mixed,
	essay: String
}, { 
	timestamps: true
})

organizationSchema.pre('save', function(next) {
	tools.preSave(this)
  next()
})

module.exports = mongoose.model('Organization', organizationSchema)