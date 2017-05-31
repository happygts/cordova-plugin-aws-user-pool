Version 1.1.0

# Introduction to the plugin

This plugin exist because there is multiples problemes using the javascript cognito userPool within cordova.
For example in some versions of Ios it's not possible to create an account, the connection take to much time and often fail. It was really impossible to find the reasons why it was failing so I decided to do this plugin.

# What's this plugin allow you to do

  * Signup users to your cognito userPool
    - with the confirmation you chosed within cognito
  * Set userData during the signup (these data are not supposed to change afterward
  * SignIn user (Online/Offline)
  * Update the password
  * Use CognitoSync linked with your userPool
    - get/set data for a user with Federated Identity

# Sample :

[Sample' Readme](https://github.com/moreaup/cordova-plugin-aws-user-pool/tree/master/Sample/awsUserPoolPluginSample/README.md)

# Usage

 1) Instalation :
 
 `cordova plugin add cordova-plugin-aws-user-pool`

 2) Initialisation :
 
 ```javascript
   this.CognitoIdentityUserPoolId = "eu-west-1_*********";
   this.CognitoIdentityUserPoolAppClientId = "*********************";
   this.CognitoIdentityUserPoolAppClientSecret = "************************";
   this.CognitoArnIdentityPoolId = "eu-west-1:********-****-****-****-************";

   var awsUserPluginInstance = new AwsUserPoolPlugin({"CognitoIdentityUserPoolId": this.CognitoIdentityUserPoolId,
      "CognitoIdentityUserPoolAppClientId": this.CognitoIdentityUserPoolAppClientId,
      "CognitoIdentityUserPoolAppClientSecret": this.CognitoIdentityUserPoolAppClientSecret,
      "arnIdentityPoolId": this.CognitoArnIdentityPoolId, "CognitoRegion": AwsUserPoolPlugin.AwsUserPoolPluginEnum.EuWest1}, function() {
      console.log("connectionPluginInstance Init Ok");
  }, function() {
      console.log("connectionPluginInstance Init Fail");
  });
 ```
 
 If you don't use the appClientSecret just set CognitoIdentityUserPoolAppClientSecret to null
 
 The arnIdentityPoolId is here if you use Federated Identity to store data and synchronise them with CognitoSync, if you don't use it set it to null
 
 3) Signup :
 
 ```javascript
  awsUserPluginInstance.signUp({"id": "UniqueId", "password" : "password",
                                "attributes": [{"oneAttribute" : "its value"}]}, function(res) {
  // Success
  }, function(err) {
    // Error
  });
 ```
 
 The Id must be unique, usually I use the email adress and change the @ with an A.
 
 Confirm signUp :
  
  ```javascript
  awsUserPluginInstance.confirmSignUp({"id": username, "token": token}, function(res) {
    console.log("User confirmed, you can now signin");
  }, function(err) {
    console.log("err :", err.message);
  });
  ```

  Resend confirmation code :

  ```javascript
  this.awsUserPluginInstance.resendConfirmationCode({"id": username}, function(res) {
      success();
  }, function(err) {
      error(err);
  });
  ```

 4) SignIn :
 
 ```javascript
awsUserPluginInstance.signIn({"username": Username, "password": password}, function(res) {
  // Success
}, function(err) {
  // Error : err
})
 ```
 
5) SignOut :

 ```javascript
awsUserPluginInstance.signOut({}, function(res) {
  // Success
}, function(err) {
  // Error : err
})
 ```

Will SignOut the last user connected

 6) Using Federated Identity
 
 After a successfull connection you will be able to create or to open a dataset :
 
 a) Create or Open an existing dataset :
 
 ```javascript
awsUserPluginInstance.signIn({"username": Username, "password": password}, function(res) {
  awsUserPluginInstance.createAWSCognitoDataset({"id": "YourDatasetId"}, function() {
    console.log("dataset ok");
  }, function() {
      console.log("error");
  });
}, function(err) {
  // Error : err
})
 ```
 
 b) Get data by key :
 
 ```javascript
 awsUserPluginInstance.getUserDataCognitoSync({"key": "yourKey"}, function(data) {
    if (data) {
        console.log("data :", JSON.parse(data));                    
    }
    // will return null if no data are set for this key
}, function() {
  // Error
});
 ```
 
 c) Set data by key :
 
```javascript
awsUserPluginInstance.setUserDataCognitoSync({"key": "yourKey", "value": JSON.stringify(obj)}, callback, errCallback);
```
 
 6) Update password :

```javascript
this.awsUserPluginInstance.updatePassword({"confirmationCode": "123456", "newPassword": "newPassword"}, function(res) {
  // Success
}, function(err) {
  // Error
})
``` 


# Framework versions

    <framework src="AWSCore" type="podspec" spec=">= 2.5.3" />
    <framework src="AWSCognito" type="podspec" spec=">= 2.5.3" />
    <framework src="AWSCognitoIdentityProvider" type="podspec" spec=">= 2.5.3" />
    <framework src="AWSLambda" type="podspec" spec=">= 2.5.3" />
    <framework src="AWSAPIGateway" type="podspec" spec=">= 2.5.3" />
