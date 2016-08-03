var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var termSchema = mongoose.Schema({
	name: {
		type: String,
		required: true
	},
	slug: String,
	definition: String,
	type: String
}, { 
	timestamps: true
});

termSchema.pre('save', function(next) {
	tools.preSave(this)
	next()
})

module.exports = mongoose.model('Term', termSchema)