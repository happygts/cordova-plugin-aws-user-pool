# How to make sample work

1) Change the credential :

go to the file www/js/index.js and change the following by your credential :

CognitoIdentityUserPoolId: "eu-west-1_*********"

CognitoIdentityUserPoolAppClientId: "*********************"

CognitoIdentityUserPoolAppClientSecret: "************************"

CognitoArnIdentityPoolId: "eu-west-1:********-****-****-****-************"

If you don't have any CognitoIdentityUserPoolAppClientSecret just set it to null

Here is where you can find your settings :

- UserPoolAppClients

![alt text](https://img15.hostingpics.net/pics/534932userPoolAppClients.png)

- UserPoolPoolDetails :

![alt text](https://img15.hostingpics.net/pics/193176UserPoolPoolDetails.png)

- FederalIdentitiesSettings

![alt text](https://img15.hostingpics.net/pics/549772FederalIdentitiesSettings.png)

cordova platform add ios

cordova plugin add ../../

cordova build ios