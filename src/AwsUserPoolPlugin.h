#import <Cordova/CDV.h>

#import "AWSCognitoIdentityProvider.h"
#import <AWSCognito/AWSCognito.h>
#import <AWSLambda/AWSLambda.h>

#import <Foundation/Foundation.h>

#import "Reachability.h"

	@interface AwsUserPoolPlugin : CDVPlugin

	@property AWSRegionType CognitoIdentityUserPoolRegion;
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
	- (void)offlineSignIn:(CDVInvokedUrlCommand*)command;
	- (void)signOut:(CDVInvokedUrlCommand *)command;
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

	@interface AWSCognitoIdentityUserPool (UserPoolsAdditions)

	- (AWSTask<NSString*>*) token;

	@end

	@interface MyManager : NSObject {
	    NSString *lastUsername;
	    NSString *lastPassword;
	}

	@property (nonatomic, retain) NSString *lastUsername;
	@property (nonatomic, retain) NSString *lastPassword;

	+ (id)sharedManager;

	@end