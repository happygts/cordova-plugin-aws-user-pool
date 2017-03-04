#import <Cordova/CDV.h>

#import "AWSCognitoIdentityProvider.h"

	@interface AwsUserPoolPlugin : CDVPlugin

	@property NSString *CognitoIdentityUserPoolId;
	@property NSString *CognitoIdentityUserPoolAppClientId;
	@property NSString *CognitoIdentityUserPoolAppClientSecret;
	@property AWSCognitoIdentityUserPool *Pool;
	@property AWSCognitoIdentityUser *User;
	
	- (void)init:(CDVInvokedUrlCommand*)command;
	- (void)signIn:(CDVInvokedUrlCommand*)command;
	- (void)signUp:(CDVInvokedUrlCommand*)command;
	- (void)confirmSignUp:(CDVInvokedUrlCommand*)command;
	- (void)forgotPassword:(CDVInvokedUrlCommand*)command;
	- (void)updatePassword:(CDVInvokedUrlCommand*)command;
	- (void)getDetails:(CDVInvokedUrlCommand*)command;
	- (void)resendConfirmationCode:(CDVInvokedUrlCommand*)command;

	@end