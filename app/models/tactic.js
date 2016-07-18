var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var tacticSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: String
}, { 
	timestamps: true
});

tacticSchema.pre('save', function(next) {
	tools.preSave(this)
	next()
})

module.exports = mongoose.model('Tactic', tacticSchema)