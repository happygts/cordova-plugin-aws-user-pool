var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec');


var AwsUserPoolPlugin = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec init with config :", config, "and params :", params);
		successCallback();
	},
	function(error) {
		console.log("[Inside plugin] error during init :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "init", [config]);
};

AwsUserPoolPlugin.prototype.signIn = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec signIn with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during signIn :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "signIn", [config]);
};

AwsUserPoolPlugin.prototype.signUp = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec signUp with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during signUp :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "signUp", [config]);
};

AwsUserPoolPlugin.prototype.confirmSignUp = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec confirmSignUp with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during confirmSignUp	 :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "confirmSignUp", [config]);
};

AwsUserPoolPlugin.prototype.forgotPassword = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec forgotPassword with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during forgotPassword :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "forgotPassword", [config]);
};

AwsUserPoolPlugin.prototype.updatePassword = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec updatePassword with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during updatePassword :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "updatePassword", [config]);
};

AwsUserPoolPlugin.prototype.getDetails = function(config, successCallback, errorCallback) {
	cordova.exec(function(userDetails) {
		console.log("[Inside plugin] cordova exec getDetails with config :", config, "and params :", userDetails);
		successCallback(userDetails);
	},
	function(error) {
		console.log("[Inside plugin] error during getDetails :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "getDetails", [config]);
};

AwsUserPoolPlugin.prototype.resendConfirmationCode = function(config, successCallback, errorCallback) {
	cordova.exec(function(params) {
		console.log("[Inside plugin] cordova exec resendConfirmationCode with config :", config, "and params :", params);
		successCallback(params);
	},
	function(error) {
		console.log("[Inside plugin] error during resendConfirmationCode :", error);
		errorCallback(error);
	}, "AwsUserPoolPlugin", "resendConfirmationCode", [config]);
};

module.exports = AwsUserPoolPlugin;