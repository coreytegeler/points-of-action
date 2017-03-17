var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var organizationSchema = mongoose.Schema({
	name: String,
	slug: {
		type: String,
		unique: true
	},
	organizationType: Mixed,
	location: Mixed,
	essay: String,
	model: {
		type: String,
		default: 'organization'
	}
}, { 
	timestamps: true
})

organizationSchema.pre('save', function(next) {
	tools.preSave(this, 'organization')
  next()
})

module.exports = mongoose.model('Organization', organizationSchema)