#import "AwsUserPoolPlugin.h"

    @implementation MyManager

    @synthesize lastUsername;
    @synthesize lastPassword;

    + (id)sharedManager {
        static MyManager *sharedMyManager = nil;
        static dispatch_once_t onceToken;

        dispatch_once(&onceToken, ^{
            sharedMyManager = [[self alloc] init];
        });
        return sharedMyManager;
    }

    - (id)init {
      if (self = [super init]) {
            lastUsername = [[NSString alloc] initWithString:@""];
            lastPassword = [[NSString alloc] initWithString:@""];
      }
      return self;
    }

    @end

    @implementation AWSCognitoIdentityUserPool (UserPoolsAdditions)

    static AWSSynchronizedMutableDictionary *_serviceClients = nil;

    - (AWSTask<NSString *> *)token {        
        MyManager *sharedManager = [MyManager sharedManager];

        return [[[self currentUser] getSession:sharedManager.lastUsername password:sharedManager.lastPassword validationData:nil]
                continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
                    return [AWSTask taskWithResult:task.result.idToken.tokenString];
                }];
    }

    @end

    @implementation AwsUserPoolPlugin

	AWSRegionType const CognitoIdentityUserPoolRegion = AWSRegionEUWest1;

    - (void)init:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

		self.CognitoIdentityUserPoolId = [options objectForKey:@"CognitoIdentityUserPoolId"];
		self.CognitoIdentityUserPoolAppClientId = [options objectForKey:@"CognitoIdentityUserPoolAppClientId"];
		self.CognitoIdentityUserPoolAppClientSecret = [options objectForKey:@"CognitoIdentityUserPoolAppClientSecret"];
        if(!self.CognitoIdentityUserPoolAppClientSecret || [self.CognitoIdentityUserPoolAppClientSecret isKindOfClass:[NSNull class]]
            || self.CognitoIdentityUserPoolAppClientSecret.length)
            self.CognitoIdentityUserPoolAppClientSecret = nil;
        self.User = nil;
        self.actualAccessToken = nil;
        self.arnIdentityPoolId = [options objectForKey:@"arnIdentityPoolId"];
        self.dataset = nil;

        self.credentialsProvider = nil;

        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:nil];

        AWSCognitoIdentityUserPoolConfiguration *userPoolConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:self.CognitoIdentityUserPoolAppClientId clientSecret:self.CognitoIdentityUserPoolAppClientSecret poolId:self.CognitoIdentityUserPoolId];

        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:userPoolConfiguration forKey:@"UserPool"];

        self.Pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];

        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoIdentityUserPoolRegion identityPoolId:self.arnIdentityPoolId identityProviderManager:self.Pool];

        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:self.credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

        self.syncClient = [AWSCognito defaultCognito];

        MyManager *sharedManager = [MyManager sharedManager];

        sharedManager.lastUsername = @"";
        sharedManager.lastPassword = @"";

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Initialization successful"];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    - (void)offlineSignIn:(CDVInvokedUrlCommand*)command {
        /*
        // The SignIn will always return true, you need to manage the signin on the cordova side.
        // This function is needed if you already signin your user with internet and you want him to access to his data
        */
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *username = [options objectForKey:@"username"];
        NSString *password = [options objectForKey:@"password"];

        MyManager *sharedManager = [MyManager sharedManager];

        sharedManager.lastUsername = username;
        sharedManager.lastPassword = password;

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"SignIn offline successful"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    - (void)signIn:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *username = [options objectForKey:@"username"];
        NSString *password = [options objectForKey:@"password"];

        self.User = [self.Pool getUser:username];
    
        [[self.User getSession:username password:password validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    MyManager *sharedManager = [MyManager sharedManager];

                    sharedManager.lastUsername = username;
                    sharedManager.lastPassword = password;

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else{
                    self.actualAccessToken = task.result.accessToken;

                    MyManager *sharedManager = [MyManager sharedManager];

                    sharedManager.lastUsername = username;
                    sharedManager.lastPassword = password;

                    [[self.credentialsProvider getIdentityId] continueWithBlock:^id _Nullable(AWSTask<NSString *> * _Nonnull task) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(task.error){
                                NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!! error : %@", task.error.userInfo);
                                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo[@"NSLocalizedDescription"]];
                                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                            } else {
                                NSString *keyString = [options objectForKey:@"key"];

                                NSString *value = [self.dataset stringForKey:keyString];

                                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"SignIn successful"];
                                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                            }
                        });
                        return nil;
                    }];
                }
            });
            return nil;
        }];
    }

    - (void)signUp:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];
        NSMutableArray * attributes = [NSMutableArray new];

        NSString *passwordString = [options objectForKey:@"password"];
        NSString *nameString = [options objectForKey:@"name"];
        NSString *idString = [options objectForKey:@"id"];
        NSString *emailString = [options objectForKey:@"email"];

        AWSCognitoIdentityUserAttributeType * email = [AWSCognitoIdentityUserAttributeType new];
        email.name = @"email";
        email.value = emailString;

        
        AWSCognitoIdentityUserAttributeType * name = [AWSCognitoIdentityUserAttributeType new];
        name.name = @"name";
        name.value = nameString;

        if(![@"" isEqualToString:email.value]){
            [attributes addObject:email];
        }
        if(![@"" isEqualToString:name.value]){
            [attributes addObject:name];
        }

        //sign up the user
        [[self.Pool signUp:idString password:passwordString userAttributes:attributes validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else{
                    AWSCognitoIdentityUserPoolSignUpResponse * response = task.result;
                    if(!response.userConfirmed){
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    else {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:false];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];                       
                    }
                }});
            return nil;
        }];
    }

    - (void)confirmSignUp:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *tokenString = [options objectForKey:@"token"];
        NSString *idString = [options objectForKey:@"id"];

        if (idString) {
            self.User = [self.Pool getUser:idString];
        }

        [[self.User confirmSignUp:tokenString forceAliasCreation:YES] continueWithBlock: ^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"good token"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
            return nil;
        }];
    }

    - (void)forgotPassword:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *idString = [options objectForKey:@"id"];        

        if (idString) {
            self.User = [self.Pool getUser:idString];
        }

        [[self.User forgotPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserForgotPasswordResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"good token"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
            return nil;
        }];
    }

    - (void)updatePassword:(CDVInvokedUrlCommand*)command {
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *confirmationCode = [options objectForKey:@"confirmationCode"];
        NSString *newPassword = [options objectForKey:@"newPassword"];

        [[self.User confirmForgotPassword:confirmationCode password:newPassword] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"good token"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
            return nil;
        }];
    }

    -(void)getDetails:(CDVInvokedUrlCommand*)command {
        AWSCognitoIdentityProviderGetUserRequest* request = [AWSCognitoIdentityProviderGetUserRequest new];
        request.accessToken = self.actualAccessToken.tokenString;

        AWSCognitoIdentityProvider *defaultIdentityProvider = [AWSCognitoIdentityProvider defaultCognitoIdentityProvider];

        [[defaultIdentityProvider getUser:request] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityProviderGetUserResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    AWSCognitoIdentityProviderGetUserResponse *response = task.result;

                    NSMutableDictionary *toReturn= [NSMutableDictionary dictionary];
                    NSUInteger size = [response.userAttributes count];

                    for (int i = 0; i < size; i++)
                    {
                        toReturn[response.userAttributes[i].name] = response.userAttributes[i].value;
                    }

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:toReturn];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
            return nil;
        }];
    }

    - (void)resendConfirmationCode:(CDVInvokedUrlCommand*)command {
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *idString = [options objectForKey:@"id"];        

        if (idString) {
            self.User = [self.Pool getUser:idString];
        }

        [[self.User resendConfirmationCode] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo[@"message"]];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                }
            });
            return nil;
        }];
    }

    /*
    ** Cognito Sync
    */

    - (void) createAWSCognitoDataset:(CDVInvokedUrlCommand *) command {
        // Add a dictionnary to allow to open multiple database

        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *idString = [options objectForKey:@"id"];
        NSString *cognitoId = self.credentialsProvider.identityId;

        self.dataset = [[AWSCognito defaultCognito] openOrCreateDataset:idString];

        self.dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
            // override and always choose remote changes
            return [conflict resolveWithRemoteRecord];
        };
        
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"NetworkingError"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[self.dataset synchronize] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.error){
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    } else {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"createAWSCognitoDataset Successful"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                });
                return nil;
            }];
        }
    }


    - (void) getUserDataCognitoSync:(CDVInvokedUrlCommand *) command {
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];
        NSString *keyString = [options objectForKey:@"key"];

        NSString *value = [self.dataset stringForKey:keyString];

        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[self.dataset synchronize] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.error){
                        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!! error : %@", task.error);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    } else {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                });
                return nil;
            }];
        }
    }

    - (void) setUserDataCognitoSync:(CDVInvokedUrlCommand *) command {
        NSString *identityId = self.credentialsProvider.identityId;
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *keyString = [options objectForKey:@"key"];
        NSString *valueString = [options objectForKey:@"value"];

        [self.dataset setString:valueString forKey:keyString];
        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"NetworkingError"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[self.dataset synchronize] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.error){
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    } else {
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"setUserDataCognitoSync Successful"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                });
                return nil;
            }];
        }
    }

    @end