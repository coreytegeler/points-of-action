var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var organizationTypeSchema = mongoose.Schema({
	name: String,
	slug: String,
}, { 
	timestamps: true
})

organizationTypeSchema.pre('save', function(next) {
	tools.preSave(this)
  next()
})

module.exports = mongoose.model('OrganizationType', organizationTypeSchema)