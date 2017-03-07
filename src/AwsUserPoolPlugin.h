#import <Cordova/CDV.h>

#import "AWSCognitoIdentityProvider.h"
#import <AWSCognito/AWSCognito.h>

	@interface AwsUserPoolPlugin : CDVPlugin

	@property NSString *CognitoIdentityUserPoolId;
	@property NSString *CognitoIdentityUserPoolAppClientId;
	@property NSString *CognitoIdentityUserPoolAppClientSecret;
	@property AWSCognitoIdentityUserPool *Pool;
	@property AWSCognitoIdentityUser *User;
	@property AWSCognitoIdentityUserSessionToken *actualAccessToken;
 	@property NSString *arnIdentityPoolId;
 	@property AWSCognito *syncClient;
 	@property AWSCognitoDataset *dataset;
 	@property AWSCognitoCredentialsProvider *credentialsProvider;

 	- (void)init:(CDVInvokedUrlCommand*)command;
	- (void)signIn:(CDVInvokedUrlCommand*)command;
	- (void)signUp:(CDVInvokedUrlCommand*)command;
	- (void)confirmSignUp:(CDVInvokedUrlCommand*)command;
	- (void)forgotPassword:(CDVInvokedUrlCommand*)command;
	- (void)updatePassword:(CDVInvokedUrlCommand*)command;
	- (void)getDetails:(CDVInvokedUrlCommand*)command;
	- (void)resendConfirmationCode:(CDVInvokedUrlCommand*)command;
	- (void)createAWSCognitoDataset:(CDVInvokedUrlCommand*) command;
	- (void)getUserDataCognitoSync:(CDVInvokedUrlCommand*) command;
    - (void)setUserDataCognitoSync:(CDVInvokedUrlCommand*) command;

	@end