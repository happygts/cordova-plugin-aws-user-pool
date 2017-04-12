/*
 Copyright 2010-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License").
 You may not use this file except in compliance with the License.
 A copy of the License is located at

 http://aws.amazon.com/apache2.0

 or in the "license" file accompanying this file. This file is distributed
 on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 express or implied. See the License for the specific language governing
 permissions and limitations under the License.
 */
 

#import <Foundation/Foundation.h>
#import <AWSAPIGateway/AWSAPIGateway.h>

#import "BYMAPPV2Empty.h"
#import "BYMAPPV2User.h"


NS_ASSUME_NONNULL_BEGIN

/**
 The service client object.
 */
@interface BYMAPPV2BYMAPPClient: AWSAPIGatewayClient

/**
 Returns the singleton service client. If the singleton object does not exist, the SDK instantiates the default service client with `defaultServiceConfiguration` from `[AWSServiceManager defaultServiceManager]`. The reference to this object is maintained by the SDK, and you do not need to retain it manually.

 If you want to enable AWS Signature, set the default service configuration in `- application:didFinishLaunchingWithOptions:`
 
 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
         AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
          AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                          identityPoolId:@"YourIdentityPoolId"];
          AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1
                                                                               credentialsProvider:credentialsProvider];
          [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

          return YES;
      }

 Then call the following to get the default service client:

 *Swift*

     let serviceClient = BYMAPPV2BYMAPPClient.defaultClient()

 *Objective-C*

     BYMAPPV2BYMAPPClient *serviceClient = [BYMAPPV2BYMAPPClient defaultClient];

 Alternatively, this configuration could also be set in the `info.plist` file of your app under `AWS` dictionary with a configuration dictionary by name `BYMAPPV2BYMAPPClient`.

 @return The default service client.
 */
+ (instancetype)defaultClient;

/**
 Creates a service client with the given service configuration and registers it for the key.

 If you want to enable AWS Signature, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         BYMAPPV2BYMAPPClient.registerClientWithConfiguration(configuration, forKey: "USWest2BYMAPPV2BYMAPPClient")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [BYMAPPV2BYMAPPClient registerClientWithConfiguration:configuration forKey:@"USWest2BYMAPPV2BYMAPPClient"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let serviceClient = BYMAPPV2BYMAPPClient(forKey: "USWest2BYMAPPV2BYMAPPClient")

 *Objective-C*

     BYMAPPV2BYMAPPClient *serviceClient = [BYMAPPV2BYMAPPClient clientForKey:@"USWest2BYMAPPV2BYMAPPClient"];

 @warning After calling this method, do not modify the configuration object. It may cause unspecified behaviors.

 @param configuration A service configuration object.
 @param key           A string to identify the service client.
 */
+ (void)registerClientWithConfiguration:(AWSServiceConfiguration *)configuration forKey:(NSString *)key;

/**
 Retrieves the service client associated with the key. You need to call `+ registerClientWithConfiguration:forKey:` before invoking this method or alternatively, set the configuration in your application's `info.plist` file. If `+ registerClientWithConfiguration:forKey:` has not been called in advance or if a configuration is not present in the `info.plist` file of the app, this method returns `nil`.

 For example, set the default service configuration in `- application:didFinishLaunchingWithOptions:`

 *Swift*

     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
         let credentialProvider = AWSCognitoCredentialsProvider(regionType: .USEast1, identityPoolId: "YourIdentityPoolId")
         let configuration = AWSServiceConfiguration(region: .USWest2, credentialsProvider: credentialProvider)
         BYMAPPV2BYMAPPClient.registerClientWithConfiguration(configuration, forKey: "USWest2BYMAPPV2BYMAPPClient")

         return true
     }

 *Objective-C*

     - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
         AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
                                                                                                         identityPoolId:@"YourIdentityPoolId"];
         AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSWest2
                                                                              credentialsProvider:credentialsProvider];

         [BYMAPPV2BYMAPPClient registerClientWithConfiguration:configuration forKey:@"USWest2BYMAPPV2BYMAPPClient"];

         return YES;
     }

 Then call the following to get the service client:

 *Swift*

     let serviceClient = BYMAPPV2BYMAPPClient(forKey: "USWest2BYMAPPV2BYMAPPClient")

 *Objective-C*

     BYMAPPV2BYMAPPClient *serviceClient = [BYMAPPV2BYMAPPClient clientForKey:@"USWest2BYMAPPV2BYMAPPClient"];

 @param key A string to identify the service client.

 @return An instance of the service client.
 */
+ (instancetype)clientForKey:(NSString *)key;

/**
 Removes the service client associated with the key and release it.
 
 @warning Before calling this method, make sure no method is running on this client.
 
 @param key A string to identify the service client.
 */
+ (void)removeClientForKey:(NSString *)key;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessB2clinkPut;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessB2clinkDelete;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessExercicePut;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessExerciceDelete;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessExerciceOptions;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessProtocolPut;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessProtocolDelete;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessUserGet;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessUserPost;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)businessUserDelete;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiOptions;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiB2clinkGet;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiB2clinkPost;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiB2clinkDelete;

/**
 
 
 @param exID 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiExerciceGet:(nullable NSString *)exID;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiExercicePost;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiExerciceOptions;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiGameGet;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiLibraryGet;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiLibraryOptions;

/**
 
 
 @param protocolID 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiProtocolGet:(nullable NSString *)protocolID;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiProtocolOptions;

/**
 
 
 @param thematicID 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiThematicGet:(nullable NSString *)thematicID;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiThematicOptions;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiUserGet;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiUserPost;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiUserOptions;

/**
 
 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiUserHead;

/**
 
 
 @param body 
 
 return type: BYMAPPV2Empty *
 */
- (AWSTask *)userapiUserV2Post:( BYMAPPV2User *)body;

@end

NS_ASSUME_NONNULL_END
