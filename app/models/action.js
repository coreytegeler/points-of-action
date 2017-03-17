var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var actionSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: {
		type: String,
		unique: true
	},
	tactics: Mixed,
	locations: Mixed,
	people: Mixed,
	organizations: Mixed,
	essayJSON: Mixed,
	essayHTML: String,
	images: Mixed,
	date: Mixed,
	model: {
		type: String,
		default: 'action'
	}
}, { 
	timestamps: true
});

actionSchema.pre('save', function(next) {
	tools.preSave(this, 'action')
	next()
})

module.exports = mongoose.model('Action', actionSchema)