/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

var app = {
    // Set these variables with your values
    CognitoIdentityUserPoolId: "eu-west-1_*********", 
    CognitoIdentityUserPoolAppClientId: "*********************", 
    CognitoIdentityUserPoolAppClientSecret: "************************",
    CognitoArnIdentityPoolId: "eu-west-1:********-****-****-****-************",

    signIn: 0,
    signUp: 1,
    data: 2,

    currentState: 0,
    currentData: null,

    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        console.log("on deviceready");
        console.log("this.CognitoIdentityUserPoolId :", this.CognitoIdentityUserPoolId, "this.CognitoIdentityUserPoolAppClientId :", this.CognitoIdentityUserPoolAppClientId, "this.CognitoIdentityUserPoolAppClientSecret :", this.CognitoIdentityUserPoolAppClientSecret);
        document.getElementById("loginRegisterDiv").style.display = "block";
        document.getElementById("dataDiv").style.display = "none";

        var CognitoRegion = AwsUserPoolPlugin.AwsUserPoolPluginEnum.EuWest1;

        this.awsUserPluginInstance = new AwsUserPoolPlugin({"CognitoIdentityUserPoolId": this.CognitoIdentityUserPoolId,
            "CognitoIdentityUserPoolAppClientId": this.CognitoIdentityUserPoolAppClientId,
            "CognitoIdentityUserPoolAppClientSecret": this.CognitoIdentityUserPoolAppClientSecret,
            "arnIdentityPoolId": this.CognitoArnIdentityPoolId, "CognitoRegion": CognitoRegion}, function() {
            console.log("connectionPluginInstance Init Ok");
        }, function() {
            console.log("connectionPluginInstance Init Fail");
        });
    },

    // Connect function
    connect: function() {
        console.log("Connect");
        var email = document.getElementById("email").value;
        var password = document.getElementById("password").value;
        var username = email.replace("@", "A");

        var self = this;

        console.log("email :", email, "password :", password);
        this.awsUserPluginInstance.signIn({"username":username, "password": password}, function(res) {
            // Success
            console.log("user well connected res:", res);
            alert("user well connected");
            self.switchToData();
        }, function(err) {
            // Error : err
            console.log("Error signin :", err)
            alert("Error :" + err.message);
            if (err.__type == "UserNotConfirmedException"){
                self.confirmSignUp(username);
            }
        })
    },

    confirmSignUp: function(username) {
        var self = this;
        var token = prompt("You received an email, check your emails at the following adress:" + email, "");
        if (token == null || token == "") {
            alert("You cancelled the prompt. You can connect yourself to validate the email.");
        } else {
            // validate email
            this.awsUserPluginInstance.confirmSignUp({"id": username, "token": token}, function(res) {
                alert("User confirmed, you can now signin");
            }, function(err) {
                console.log("err :", err.message);
                alert("Error :" + err.message);
                self.confirmSignUp(username);
            });
        }
    },

    register: function() {
        console.log("Register");
        var email = document.getElementById("email").value;
        var password = document.getElementById("password").value;
        var username = email.replace("@", "A");

        var self = this;

        console.log("email :", email, "password :", password);

        this.awsUserPluginInstance.signUp({"id": username, "password" : password,
                                        "attributes": [{"name": "email", "value": email}]}, function(res) {
            self.confirmSignUp(username);
        }, function(err) {
            console.log("err :", err);
            alert("err :" + err.message);
        });
    },

    validate: function() {
        if (this.currentState == this.signIn)
            this.connect();
        else if (this.currentState == this.signUp)
            this.register();
    },

    switch: function() {
        var buttonValidate = ["Connect", "Register"];
        var buttonTop = ["signUp", "signIn"];

        if (this.currentState == this.data) {
            console.log("logout");
            var self = this;
            this.logout(function() {
                self.currentState = self.signIn;
        
                document.getElementById("loginRegisterDiv").style.display = "block";
                document.getElementById("dataDiv").style.display = "none";
                document.getElementById("topSwitchButton").value = buttonTop[self.currentState];
                document.getElementById("buttonValidate").value = buttonValidate[self.currentState];
            }, function() {

            });
        }
        else {
            console.log("switch");
            this.currentState = (this.currentState == this.signIn ? this.signOut : this.signIn);

            document.getElementById("topSwitchButton").value = buttonTop[this.currentState];
            document.getElementById("buttonValidate").value = buttonValidate[this.currentState];
        }
    },

    switchToData: function() {
        var self = this;

        this.currentState = this.data;
        this.awsUserPluginInstance.createAWSCognitoDataset({"id": "dataID"}, function() {
            console.log("dataset ok");
            self.awsUserPluginInstance.getUserDataCognitoSync({"key": "key"}, function(data) {
                // will return null if no data are set for this key
                document.getElementById("topSwitchButton").value = "Logout";
                document.getElementById("loginRegisterDiv").style.display = "none";
                document.getElementById("dataDiv").style.display = "block";
                if (data) {
                    console.log("data :", JSON.parse(data));
                    self.currentData = JSON.parse(data);
                    document.getElementById("dataToChange").value = self.currentData.dataToChange;
                }
                else
                    self.currentData = null;
            }, function(err) {
                console.log("error getUserDataCognitoSync :", err);
            });
        }, function() {
            console.log("error");
        });
    },

    saveData: function() {
        var value = document.getElementById("dataToChange").value;

        this.awsUserPluginInstance.setUserDataCognitoSync({"key": "key", "value": JSON.stringify({"dataToChange" : value})}, function() {
            alert("data well saved");
        }, function(err) {
            console.log("err :", err);
            alert("Error saving data :", err);
        });
    },

    logout: function(successCallback, errCallback) {
        this.awsUserPluginInstance.signOut({}, function(res) {
            // Success
            console.log("logout Success");
            successCallback();
        }, function(err) {
            console.log("err :", err);
            alert("Error while logout :", err.message);
            errCallback();
        })
    }
};

app.initialize();