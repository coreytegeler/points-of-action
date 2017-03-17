var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var termSchema = mongoose.Schema({
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
		default: 'term'
	}
}, { 
	timestamps: true
});

termSchema.pre('save', function(next) {
	tools.preSave(this, 'term')
	next()
})

module.exports = mongoose.model('Term', termSchema)