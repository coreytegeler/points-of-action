var mongoose = require('mongoose')
var passportLocalMongoose = require('passport-local-mongoose')
var tools = require('../tools')

var userSchema = mongoose.Schema({
	email: {
		type: String,
		required: true,
		unique: true
	},
	firstName: {
		type: String
	},
	lastName: {
		type: String
	},
	name: String,
	slug: String,
	password: String,
	username: String
}, { 
	timestamps: true
});

userSchema.pre('save', function(next) {
	this.username = this.email
	this.name = this.firstName + ' ' + this.lastName
  tools.preSave(this)
  next();
});

userSchema.plugin(passportLocalMongoose, {
	usernameField: 'email',
  usernameQueryFields: ['email'],
  usernameLowerCase: true
});

module.exports = mongoose.model('User', userSchema);