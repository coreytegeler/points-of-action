var tools = require('../tools')
var mongoose = require('mongoose')
var Mixed = mongoose.Schema.Types.Mixed

var personTypeSchema = mongoose.Schema({
	name: String,
	slug: {
		type: String,
		unique: true
	},
	model: {
		type: String,
		default: 'personType'
	}
}, { 
	timestamps: true
})

personTypeSchema.pre('save', function(next) {
	tools.preSave(this, 'personType')
  next()
})

module.exports = mongoose.model('PersonType', personTypeSchema)