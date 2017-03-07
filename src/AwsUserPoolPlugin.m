#import "AwsUserPoolPlugin.h"

    @implementation AwsUserPoolPlugin

	AWSRegionType const CognitoIdentityUserPoolRegion = AWSRegionEUWest1;

    - (void)init:(CDVInvokedUrlCommand*)command{
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! INIT");
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

		self.CognitoIdentityUserPoolId = [options objectForKey:@"CognitoIdentityUserPoolId"];
		self.CognitoIdentityUserPoolAppClientId = [options objectForKey:@"CognitoIdentityUserPoolAppClientId"];
		self.CognitoIdentityUserPoolAppClientSecret = [options objectForKey:@"CognitoIdentityUserPoolAppClientSecret"];
        self.User = nil;
        self.actualAccessToken = nil;
        self.arnIdentityPoolId = [options objectForKey:@"arnIdentityPoolId"];
        self.dataset = nil;

        //setup service config
        AWSServiceConfiguration *serviceConfiguration = nil;
        self.credentialsProvider = nil;

        if (self.arnIdentityPoolId) {
            self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoIdentityUserPoolRegion identityPoolId:self.arnIdentityPoolId];
        }

        // save defaultServiceConfiguration
        serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:CognitoIdentityUserPoolRegion credentialsProvider:self.credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = serviceConfiguration;

        //create a pool
        AWSCognitoIdentityUserPoolConfiguration *configuration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:self.CognitoIdentityUserPoolAppClientId  clientSecret:self.CognitoIdentityUserPoolAppClientSecret poolId:self.CognitoIdentityUserPoolId];
        
        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:configuration forKey:@"UserPool"];

        self.Pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Initialization successful"];

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
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else{
                    self.actualAccessToken = task.result.accessToken;

                    if (self.arnIdentityPoolId) {
                        self.syncClient = [AWSCognito defaultCognito];
                    }

                    if (self.credentialsProvider){
                        [self.credentialsProvider clearCredentials];
                    }

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Authentification sucess"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
        //confirm forgot password with input from ui.

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
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else {
                    AWSCognitoIdentityProviderGetUserResponse *response = task.result;
                    NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
                    NSLog(@"%@", response.userAttributes);
                    NSLog(@"%@", response.userAttributes[0]);
                    NSLog(@"%@", response.userAttributes[0].name);
                    NSLog(@"%@", response.userAttributes[0].value);

                    NSMutableDictionary *toReturn= [NSMutableDictionary dictionary];
                    NSUInteger size = [response.userAttributes count];

                    for (int i = 0; i < size; i++)
                    {
                        toReturn[response.userAttributes[i].name] = response.userAttributes[i].value;
                    }

                    NSLog(@"Dictionnary :");
                    NSLog(@"%@", toReturn);

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
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"error"];
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

        self.dataset = [self.syncClient openOrCreateDataset:idString];

        // self.dataset = [[AWSCognito defaultCognito] openOrCreateDataset:datasetName];:@"user_data"];

        self.dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
            // override and always choose remote changes
            return [conflict resolveWithRemoteRecord];
        };

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }


    - (void) getUserDataCognitoSync:(CDVInvokedUrlCommand *) command {
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *keyString = [options objectForKey:@"key"];

        NSString *value = [self.dataset stringForKey:keyString];

        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Result value :");
        NSLog(value);

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    - (void) setUserDataCognitoSync:(CDVInvokedUrlCommand *) command {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! Inside setUserDataCognitoSync :");
        NSString *identityId = credentialsProvider.identityId;
        NSLog(@"identityId : %@", identityId);
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *keyString = [options objectForKey:@"key"];
        NSString *valueString = [options objectForKey:@"value"];

        [self.dataset setString:valueString forKey:keyString];
        [self.dataset synchronize];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

    @end