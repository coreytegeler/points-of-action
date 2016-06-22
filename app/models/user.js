var tools = require('../tools')
var mongoose = require('mongoose');
var bcrypt   = require('bcrypt-nodejs');

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
	password: {
		type: String,
		required: true
	}
}, { 
	timestamps: true
});

userSchema.pre('save', function(next) {
	this.name = this.firstName + ' ' + this.lastName
  tools.preSave(this)
  next();
});

userSchema.methods.generateHash = function(password) {
  return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
};

userSchema.methods.validPassword = function(password) {
  return bcrypt.compareSync(password, this.password);
};

module.exports = mongoose.model('User', userSchema);