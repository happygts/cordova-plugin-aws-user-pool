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

    - (AWSTask<NSString *> *)token {        
        MyManager *sharedManager = [MyManager sharedManager];

        return [[[self currentUser] getSession:sharedManager.lastUsername password:sharedManager.lastPassword validationData:nil]
                continueWithSuccessBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
                    return [AWSTask taskWithResult:task.result.idToken.tokenString];
                }];
    }

    @end

    @implementation AwsUserPoolPlugin

    - (void)init:(CDVInvokedUrlCommand*)command{
        [AWSDDLog sharedInstance].logLevel = AWSDDLogLevelVerbose;
        [AWSDDLog addLogger:[AWSDDTTYLogger sharedInstance]];

        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        self.CognitoIdentityUserPoolId = [options objectForKey:@"CognitoIdentityUserPoolId"];
        self.CognitoIdentityUserPoolAppClientId = [options objectForKey:@"CognitoIdentityUserPoolAppClientId"];
        self.CognitoIdentityUserPoolAppClientSecret = [options objectForKey:@"CognitoIdentityUserPoolAppClientSecret"];
        
        switch ([[options objectForKey:@"CognitoRegion"] intValue])
        {
            case 0:
                self.CognitoIdentityUserPoolRegion = AWSRegionUnknown;
                break;
            case 1:
                self.CognitoIdentityUserPoolRegion = AWSRegionUSEast1;
                break;
            case 2:
                self.CognitoIdentityUserPoolRegion = AWSRegionUSEast2;
                break;
            case 3:
                self.CognitoIdentityUserPoolRegion = AWSRegionUSWest1;
                break;
            case 4:
                self.CognitoIdentityUserPoolRegion = AWSRegionUSWest2;
                break;
            case 5:
                self.CognitoIdentityUserPoolRegion = AWSRegionAPSouth1;
                break;
            case 6:
                self.CognitoIdentityUserPoolRegion = AWSRegionAPNortheast1;
                break;
            case 7:
                self.CognitoIdentityUserPoolRegion = AWSRegionAPNortheast2;
                break;
            case 8:
                self.CognitoIdentityUserPoolRegion = AWSRegionAPSoutheast1;
                break;
            case 9:
                self.CognitoIdentityUserPoolRegion = AWSRegionAPSoutheast2;
                break;
            case 10:
                self.CognitoIdentityUserPoolRegion = AWSRegionEUCentral1;
                break;
            case 11:
                self.CognitoIdentityUserPoolRegion = AWSRegionEUWest1;
                break;
            case 12:
                self.CognitoIdentityUserPoolRegion = AWSRegionEUWest2;
                break;
            default:
                self.CognitoIdentityUserPoolRegion = -1;
        }
        
        if([self.CognitoIdentityUserPoolAppClientSecret isKindOfClass:[NSNull class]]
            || self.CognitoIdentityUserPoolAppClientSecret.length == 0)
            self.CognitoIdentityUserPoolAppClientSecret = nil;
        self.User = nil;
        self.actualAccessToken = nil;
        self.arnIdentityPoolId = [options objectForKey:@"arnIdentityPoolId"];
        self.dataset = nil;

        self.credentialsProvider = nil;

        AWSServiceConfiguration *serviceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:self.CognitoIdentityUserPoolRegion credentialsProvider:nil];

        AWSCognitoIdentityUserPoolConfiguration *userPoolConfiguration = [[AWSCognitoIdentityUserPoolConfiguration alloc] initWithClientId:self.CognitoIdentityUserPoolAppClientId clientSecret:self.CognitoIdentityUserPoolAppClientSecret poolId:self.CognitoIdentityUserPoolId];

        [AWSCognitoIdentityUserPool registerCognitoIdentityUserPoolWithConfiguration:serviceConfiguration userPoolConfiguration:userPoolConfiguration forKey:@"UserPool"];

        self.Pool = [AWSCognitoIdentityUserPool CognitoIdentityUserPoolForKey:@"UserPool"];

        self.credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:self.CognitoIdentityUserPoolRegion identityPoolId:self.arnIdentityPoolId identityProviderManager:self.Pool];

        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:self.CognitoIdentityUserPoolRegion credentialsProvider:self.credentialsProvider];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

        //self.syncClient = [AWSCognito defaultCognito];
        [AWSCognito registerCognitoWithConfiguration:configuration forKey:@"CognitoSync"];
        MyManager *sharedManager = [MyManager sharedManager];

        sharedManager.lastUsername = @"";
        sharedManager.lastPassword = @"";

        if (self.CognitoIdentityUserPoolRegion == -1) {
            NSLog(@"Error, you need to set region");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"You need to set region"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];            
        }
        else {
            NSLog(@"Initialization successful");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Initialization successful"];

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
    }


    - (void)offlineSignIn:(CDVInvokedUrlCommand*)command {
        /*
        // The SignIn will always return true, you need to manage the signin on the cordova side.
        // This function is needed if you already signin your user with internet and you want him to access to his data even in offline mode
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
                    NSLog(@"error : %@", task.error.userInfo);
                    MyManager *sharedManager = [MyManager sharedManager];

                    sharedManager.lastUsername = username;
                    sharedManager.lastPassword = password;

                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
                    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                } else{
                    self.actualAccessToken = task.result.accessToken;

                    MyManager *sharedManager = [MyManager sharedManager];

                    sharedManager.lastUsername = username;
                    sharedManager.lastPassword = password;

                    NSLog(@"!!!!!!!!!!! getIdentityId will start inside signIn");
                    [[self.credentialsProvider getIdentityId] continueWithBlock:^id _Nullable(AWSTask<NSString *> * _Nonnull task) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(task.error){
                                NSLog(@"!!!!!!!!!!! getIdentityId inside signIn, error : %@", task.error.userInfo);
                                CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo[@"NSLocalizedDescription"]];
                                [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                            } else {
                                NSLog(@"!!!!!!!!!!! getIdentityId inside signIn, task.result : %@", task.result);

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

    - (void)signOut:(CDVInvokedUrlCommand *)command {
        self.User = [self.Pool currentUser];

        if (![self.CognitoIdentityUserPoolAppClientSecret isKindOfClass:[NSNull class]]) {
            NSLog(@"!!!!!!!!!!! getIdentityId will start inside signOut");
            [[self.credentialsProvider getIdentityId] continueWithBlock:^id _Nullable(AWSTask<NSString *> * _Nonnull task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(task.error){
                        NSLog(@"!!!!!!!!!!! getIdentityId inside SignOut, error : %@", task.error.userInfo);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo[@"NSLocalizedDescription"]];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    } else {
                        NSLog(@"!!!!!!!!!!! getIdentityId inside SignOut, task.result : %@", task.result);

                        [self.User signOut];

                        [self.credentialsProvider clearKeychain];

                        MyManager *sharedManager = [MyManager sharedManager];

                        sharedManager.lastUsername = @"";
                        sharedManager.lastPassword = @"";

                        self.dataset = nil;

                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"SignOut successful"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                });
                return nil;
            }]  ;
        }
        else {
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"No user connected"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];           
        }
    }

    - (void)signUp:(CDVInvokedUrlCommand*)command{
        NSMutableDictionary* options = [command.arguments objectAtIndex:0];

        NSString *passwordString = [options objectForKey:@"password"];
        NSString *idString = [options objectForKey:@"id"];

        NSMutableArray* attributes = [options objectForKey:@"attributes"];
        NSMutableArray* attributesToSend = [NSMutableArray new];

        NSUInteger size = [attributes count];

        for (int i = 0; i < size; i++)
        {
            NSMutableDictionary* attributesIndex = [attributes objectAtIndex:i];

            AWSCognitoIdentityUserAttributeType * tmp = [AWSCognitoIdentityUserAttributeType new];

            tmp.name  = [attributesIndex objectForKey:@"name"];
            tmp.value = [attributesIndex objectForKey:@"value"];

            [attributesToSend addObject:tmp];
        }

        //sign up the user
        [[self.Pool signUp:idString password:passwordString userAttributes:attributesToSend validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserPoolSignUpResponse *> * _Nonnull task) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(task.error){
                    NSLog(@"error : %@", task.error);
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
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
                    NSLog(@"error : %@", task.error);
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
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
                    NSLog(@"error : %@", task.error);
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
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
                    NSLog(@"error : %@", task.error);
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
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
                    NSLog(@"error : %@", task.error);
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
                    NSLog(@"error : %@", task.error);
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

        NSLog(@"createAWSCognitoDataset idString : %@", idString);
        NSLog(@"createAWSCognitoDataset cognitoId : %@", cognitoId);

        AWSCognito *syncClient = [AWSCognito CognitoForKey:@"CognitoSync"];

        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
            self.dataset = [syncClient openOrCreateDataset:idString];

            self.dataset.conflictHandler = ^AWSCognitoResolvedConflict* (NSString *datasetName, AWSCognitoConflict *conflict) {
                // override and always choose remote changes
                return [conflict resolveWithRemoteRecord];
            };
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"NetworkingError"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[syncClient refreshDatasetMetadata] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.error){
                        NSLog(@"createAWSCognitoDataset refreshDatasetMetadata error : %@", task.error);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    else {
                        NSLog(@"createAWSCognitoDataset refreshDatasetMetadata success : %@", task.result);
                        self.dataset = [syncClient openOrCreateDataset:idString];

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
                                    if (task.isCancelled) {
                                        NSLog(@"createAWSCognitoDataset isCancelled : %@", task.isCancelled);
                                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Canceled"];
                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                    }
                                    else if(task.error){
                                        NSLog(@"createAWSCognitoDataset error : %@", task.error);
                                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                    } else {
                                        NSLog(@"createAWSCognitoDataset success : %@", task.result);
                                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"createAWSCognitoDataset Successful"];
                                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                                    }
                                });
                                return nil;
                            }];
                        }
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

        NSLog(@"getUserDataCognitoSync, value : %@", value);
        NSLog(@"getUserDataCognitoSync, keyString: %@", keyString);

        if ([[Reachability reachabilityForInternetConnection]currentReachabilityStatus] == NotReachable) {
            NSLog(@"getUserDataCognitoSync failed NetworkingError");
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:value];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[self.dataset synchronize] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.isCancelled) {
                        NSLog(@"getUserDataCognitoSync isCancelled : %@", task.isCancelled);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Canceled"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    else if(task.error){
                        NSLog(@"getUserDataCognitoSync error : %@", task.error);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:task.error.userInfo];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    } else {
                        NSLog(@"getUserDataCognitoSync success : %@", value);
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
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"NetworkingError, data saved localy"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        else {
            [[self.dataset synchronize] continueWithBlock:^id(AWSTask *task) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (task.isCancelled) {
                        NSLog(@"isCancelled : %@", task.isCancelled);
                        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Canceled"];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                    }
                    else if(task.error){
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








