# Prerequisites

The generated SDK depends on the AWS Mobile SDK for iOS. There are three ways to import it into your project:

* CocoaPods
* Frameworks
* Carthage

You should use one of these two ways to import the AWS Mobile SDK but not both. Importing both ways loads two copies of the SDK into the project and causes compiler errors.

## With CocoaPods

1. The AWS Mobile SDK for iOS is available through [CocoaPods](https://cocoapods.org/). If you have not installed CocoaPods, install it by running the command:

		$ gem install cocoapods
		$ pod setup

    Depending on your system settings, you may have to use `sudo` for installing `cocoapods` as follows:

		$ sudo gem install cocoapods
		$ pod setup


1. Move the generated `Podfile` to the same directory as your Xcode project file. Additionally starting from CocoaPods 1.0.0 you need to explicitly mention the target. To do this update the `<YourXCodeTarget>` section in `Podfile`.  If your project already has `Podfile`, you can add the following line to the existing `Podfile`.

        pod 'AWSAPIGateway', '~> 2.4.2'

1. Then run the following command:

        $ pod install

1. Open up `*.xcworkspace` with Xcode.
1. Add all files (`*.h` and `*.m` files) under the `generated-src` directory to your Xcode project. If you are using swift then xcode will automatically ask **Would you like to configure an Objective-C bridging header?** select **Create Bridging header** option, Then add the following in the bridging header file that xcode created.
        
        #import "BYMAPPV2BYMAPPClient.h"

## With Frameworks

1. Download the SDK from [http://aws.amazon.com/mobile/sdk](http://aws.amazon.com/mobile/sdk). Amazon API Gateway is supported with the version 2.4.0 and later.
1. With your project open in Xcode, select your **Target**. Under **General** tab, find **Embedded Binaries** and then click the **+** button.
1. Click the **Add Other...** button, navigate to the `AWSCore.framework` & `AWSAPIGateway.framework` files and select them. Check the **Destination: Copy items if needed** checkbox when prompted.
1. Under the **Buid Phases** tab in your **Target**, click the **+** button on the top left and then select **New Run Script Phase**. Then setup the build phase as follows. Make sure this phase is below the `Embed Frameworks` phase.

        Shell /bin/sh
        
        bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/AWSCore.framework/strip-frameworks.sh"
        
        Show environment variables in build log: Checked
        Run script only when installing: Not checked
        
        Input Files: Empty
        Output Files: Empty

## With Carthage

1. Install the latest version of [Carthage](https://github.com/Carthage/Carthage#installing-carthage).

1. Add the following to your `Cartfile`:

        github "aws/aws-sdk-ios"

1. Then run the following command:
	
		$ carthage update

1. With your project open in Xcode, select your **Target**. Under **General** tab, find **Embedded Binaries** and then click the **+** button.


1. Click the **Add Other...** button, navigate to the `AWS<#ServiceName#>.framework` files under `Carthage` > `Build` > `iOS` and select them. Do not check the **Destination: Copy items if needed** checkbox when prompted.

	    * `AWSCore.framework`
	    * `AWSAPIGateway.framework`

1. Under the **Buid Phases** tab in your **Target**, click the **+** button on the top left and then select **New Run Script Phase**. Then setup the build phase as follows. Make sure this phase is below the `Embed Frameworks` phase.

        Shell /bin/sh
        
        bash "${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/AWSCore.framework/strip-frameworks.sh"
        
        Show environment variables in build log: Checked
        Run script only when installing: Not checked
        
        Input Files: Empty
        Output Files: Empty
        
# Use the SDK in your project

##  Objective C
1. First import the generated header file

		#import "BYMAPPV2BYMAPPClient.h"
		
1. Then grab the `defaultClient` from your code

		BYMAPPV2BYMAPPClient *client = [BYMAPPV2BYMAPPClient defaultClient];

1. You can now call your method using the client SDK

		
		[[client businessB2clinkPut] continueWithBlock:^id(AWSTask *task) {
		    if (task.error) {
		        NSLog(@"Error: %@", task.error);
		        return nil;
		    }
		    if (task.result) {
		       BYMAPPV2Empty * output = task.result;
		       //Do something with output
		    }
		    return nil;
		}];
		

#Using AWS IAM for authorization
To use AWS IAM to authorize API calls you can set an `AWSCredentialsProvider` object as the default provider for the SDK.

		AWSStaticCredentialsProvider *creds = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:@"" secretKey:@""];
		    
		AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:creds];
		    
		AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
		
		// you can also use Amazon Cognito to retrieve temporary credentials
		AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast1
		        identityPoolId:CognitoPoolID];


#Using API Keys
You can set the `apiKey` property of the generated SDK to send API Keys in your requests.


		client.APIKey = @"your api key";
		
