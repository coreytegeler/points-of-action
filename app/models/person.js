var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var personSchema = mongoose.Schema({
	firstName: {
		type: String,
		required: true
	},
	lastName: {
		type: String,
		required: true
	},
	name: String,
	slug: String,
	type: Mixed,
	locations: Mixed,
	organizations: Mixed,
	description: String
}, { 
	timestamps: true
})

personSchema.pre('save', function(next) {
	this.name = this.firstName + ' ' + this.lastName
  tools.preSave(this)
  next()
})

module.exports = mongoose.model('Person', personSchema)