var tools = require('../tools')
var mongoose = require('mongoose')

var imageSchema = mongoose.Schema({
	filename: String,
	original: String,
	medium: String,
	small: String,
	caption: String
}, { 
	timestamps: true
});

imageSchema.pre('save', function(next) {
	this.type = 'image'
	next()
})

module.exports = mongoose.model('Image', imageSchema)