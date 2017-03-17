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
	slug: {
		type: String,
		unique: true
	},
	personType: Mixed,
	locations: Mixed,
	organizations: Mixed,
	description: String,
	model: {
		type: String,
		default: 'person'
	}
}, { 
	timestamps: true
})

personSchema.pre('save', function(next) {
  tools.preSave(this, 'person')
  next()
})

module.exports = mongoose.model('Person', personSchema)