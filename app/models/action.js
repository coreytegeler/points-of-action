var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var actionSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: String,
	tactic: Mixed,
	location: Mixed,
	people: Mixed,
	organization: Mixed,
	essayJSON: String,
	essayHTML: String,
	images: Mixed,
	type: String,
	month: Mixed,
	day: Mixed,
	year: Mixed
}, { 
	timestamps: true
});

actionSchema.pre('save', function(next) {
	tools.preSave(this, 'action')
	next()
})

module.exports = mongoose.model('Action', actionSchema)