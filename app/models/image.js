var tools = require('../tools')
var mongoose = require('mongoose')

var imageSchema = mongoose.Schema({
	name: String,
	slug: {
		type: String,
		unique: true
	},
	filename: String,
	original: String,
	medium: String,
	small: String,
	caption: String,
	model: {
		type: String,
		default: 'image'
	}
}, { 
	timestamps: true
});

imageSchema.pre('save', function(next) {
	tools.preSave(this, 'image')
	next()
})

module.exports = mongoose.model('Image', imageSchema)