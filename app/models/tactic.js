var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var tacticSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: {
		type: String,
		unique: true
	},
	definition: String,
	model: {
		type: String,
		default: 'tactic'
	}
}, { 
	timestamps: true
});

tacticSchema.pre('save', function(next) {
	tools.preSave(this, 'tactic')
	next()
})

module.exports = mongoose.model('Tactic', tacticSchema)