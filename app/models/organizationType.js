var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var organizationTypeSchema = mongoose.Schema({
	title: String,
	slug: String,
	type: String
}, { 
	timestamps: true
})

organizationTypeSchema.pre('save', function(next) {
	tools.preSave(this, 'organizationType')
  next()
})

module.exports = mongoose.model('OrganizationType', organizationTypeSchema)