# RcurlAWS
RcurlAWS is a package for R intended to facilitate use of AWS services without external dependencies.

Primary development is around credential management (both root and STS), somewhat robust use of cerdential/config files, and generic API requests.

Aws Root and Temporary credential management implemented using R6 classes.  STS is supported to generate temporary credentials.

Helper functions to access AWS services via Rcurl -> libcurl -> Rest API  
-This is under active development, limited functionality is currently implemented in wrappers which obscure the worker functions.  
-In theroy any HTTP(S) style request to the AWS REST API is possible with the worker functions.  
-I plan to add high-level functionality (via wrappers [eventually documented]) as I need probably in other linkes libraries specific to the AWS service being invoked like S3, SQS, etc.  
 
## Install

Want to try out RcurlAWS

```R
#Don't have the devtools package yet? To get going, check out:
#https://www.rstudio.com/products/rpackages/devtools/

#RcurlAWS is hosted on Git.
devtools::install_github("AlonzoBarnett/RcurlAWS", ref = 'prep_initial_commit')
```
## Tutorial

RcurlAWS contains the typical R-style documentation, .Rd help files.  So if you are unsure what to do just type ?RcurlAWS.  There are credential manager classes which facilitate use of STS with Root credentials.

### AWS Credentials on an EC2 using an IAM Profile

```R
library(RcurlAWS)

#With an instance IAM profile, invoking credentials is as easy as:

awsCreds <- AWSTemporaryCredentials$new()

#Temp credential expiration/rotation is handled in the awsRestRequest, so you shouldn't need to repeatedly check.

```

### AWS Credentials using Root access and secret from a file with profiles AND STS assumed role
```R
library(RcurlAWS)

#Assuming you are using the default setup for config/credentials files:
rootCreds <- AWSRootCredentials$new()

rootCreds <- AWSRootCredentials$new(profileName = 'psmDataScientist')

#Make an STS call to generate temp credentials.
#If you store MFA/role information in your config/credential files,
#  the information will be available in your root cred object.
awsCreds <- AWSTemporaryCredentials$new(
    rootCreds,
    roleArn = rootCreds[['profileSettings']][['ROLE_ARN']],
    MFADeviceSerialNumber = rootCreds[['profileSettings']][['MFA_SERIAL']]
)

#
#If you want to try rotating temp credentials manually,
#   use something like the below to refresh the S3 temp credentials.
#   You will be asked for an MFA Token if one is necessary.

if (awsCreds$hasExpired()) awsCreds$rotate()

```

### awsRestRequest Example  

awsRequest is the low level function that specialized service handlers use.  Spirit of design is similar to how AWS SDKs have specific modules for each service.  As a generic function, awsRestRequest, can be used to make most AWS Rest-ful API requests.  

The default parameters are setup to GET an object from S3.  The below example uses public data stored in AWS S3.  The examle object is from the [Global Database of Events, Language and Tone (GDELT) "GDELT"](https://registry.opendata.aws/gdelt/).  

```R

#To pull the object, we feed awsRestRequest the path (bucket name + the object key)
#This returns a raw object with a bunch of binary data.
myObj <- awsRestRequest(
    credentials = awsCreds,
    path = 'gdelt-open-data/events/20150906.export.csv')
)

#Without passing a conversion function to awsRestRequest, it is up to you to convert the raw object response to something R can understand.
myData <- read.delim(textConnection(rawToChar(myObj)), header = F)

```