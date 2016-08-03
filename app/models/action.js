var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var actionSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: String,
	tactics: Mixed,
	locations: Mixed,
	people: Mixed,
	organizations: Mixed,
	essay: String,
	type: String
}, { 
	timestamps: true
});

actionSchema.pre('save', function(next) {
	tools.preSave(this)
	next()
})

module.exports = mongoose.model('Action', actionSchema)