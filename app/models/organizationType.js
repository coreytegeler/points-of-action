var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var organizationTypeSchema = mongoose.Schema({
	name: String,
	slug: {
		type: String,
		unique: true
	},
	model: {
		type: String,
		default: 'organizationType'
	}
}, { 
	timestamps: true
})

organizationTypeSchema.pre('save', function(next) {
	tools.preSave(this, 'organizationType')
  next()
})

module.exports = mongoose.model('OrganizationType', organizationTypeSchema)