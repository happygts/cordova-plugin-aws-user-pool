Version 1.0.0

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

# Usage

 1) Initialisation :
 
 ```javascript
   this.cognitoIdentityUserPoolId = "eu-west-1_*********";
   this.cognitoIdentityUserPoolAppClientId = "*********************";
   this.CognitoIdentityUserPoolAppClientSecret = "************************";
   this.CognitoArnIdentityPoolId = "eu-west-1:********-****-****-****-************";

   var awsUserPluginInstance = new AwsUserPoolPlugin({"CognitoIdentityUserPoolId": ,
      "CognitoIdentityUserPoolAppClientId": this.cognitoIdentityUserPoolAppClientId,
      "CognitoIdentityUserPoolAppClientSecret": this.CognitoIdentityUserPoolAppClientSecret,
      "arnIdentityPoolId": this.CognitoArnIdentityPoolId}, function() {
      console.log("connectionPluginInstance Init Ok");
  }, function() {
      console.log("connectionPluginInstance Init Fail");
  });
 ```
 
 If you don't use the appClientSecret just set CognitoIdentityUserPoolAppClientSecret to null
 
 The arnIdentityPoolId is here if you use Federated Identity to store data and synchronise them with CognitoSync, if you don't use it set it to null
 
 2) Signup :
 
 ```javascript
  awsUserPluginInstance.signUp({"id": "UniqueId", "password" : "password",
                                "attributes": [{"oneAttribute" : "its value"}]}, function(res) {
  // Success
  }, function(err) {
    // Error
  });
 ```
 
 The Id must be unique, usually I use the email adress and change the @ with an A.
 
 3) SignIn :
 
 ```javascript
awsUserPluginInstance.signIn({"username": Username, "password": password}, function(res) {
  // Success
}, function(err) {
  // Error : err
})
 ```
 
4) SignOut :

 ```javascript
awsUserPluginInstance.signOut({}, function(res) {
  // Success
}, function(err) {
  // Error : err
})
 ```

Will SignOut the last user connected

 5) Using Federated Identity
 
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
