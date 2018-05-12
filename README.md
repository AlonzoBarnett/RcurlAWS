### RcurlAWS
RcurlAWS is a package for R intended to facilitate use of AWS services without external dependencies.

Primary development is around credential management (both root and STS) and generic API requests.

Aws Root and Temporary credential management implemented using R6 classes.  STS is supported to generate temporary credentials.

Helper functions to access AWS services via Rcurl -> libcurl -> Rest API  
-This is under active development, limited functionality is currently implemented in wrappers which obscure the worker functions.  
-In theroy any HTTP(S) style request to the AWS REST API is possible with the worker functions.  
-I plan to add high-level functionality (via wrappers [eventually documented]) as I need probably in other linkes libraries specific to the AWS service being invoked like S3, SQS, etc.  
 
### Install

Want to try out RcurlAWS

```R
#Don't have the devtools package yet? To get going, check out:
#https://www.rstudio.com/products/rpackages/devtools/

#RcurlAWS is hosted internally on Git.
devtools::install_git("https://github.com/AlonzoBarnett/RcurlAWS.git")

```
### Tutorial

RcurlAWS contains the typical R-style documentation, .Rd help files.  So if you are unsure what to do just type ?RcurlAWS.  There are credential manager classes which facilitate use of STS with Root credentials.

#### AWS Credentials on an EC2 using IAM

```R
library(RcurlAWS)

awsCreds <- AWSTemporaryCredentials$new()
#With an instance IAM profile, it is just that easy.
#If you are running a session for a long time and the credentials may expire and need to be rotated,
#   use something like the below to refresh the S3 temp credentials.
#   With instance profile derived object, user doesn't need to interact.

if (awsCreds$hasExpired()) awsCreds$rotate()

```

#### AWS Credentials using Root access and secret from a file with profiles AND STS assumed role
```R
rootCreds <- AWSRootCredentials$new(sourceFile = "...path_to_credential_file...")
#Make an STS call to generate temp credentials.
awsCreds <- AWSTemporaryCredentials$new(rootCreds,
    roleArn = '...arn_for_IAMRole...',
    RoleSessionName = sprintf("%s_tmpSession_%s", rootCreds$AWS_ACCESS_KEY_ID, format(Sys.time(), '%Y%m%d_%H%M%S')), #should just put this in the method.
    MFADeviceSerialNumber = "...arn_for_MFADevice..."
)

#
#If you are running a session for a long time and the credentials may expire and need to be rotated,
#   use something like the below to refresh the S3 temp credentials.
#   You will be asked for a MFA Token if you are running with an IAM profile.

if (awsCreds$hasExpired()) awsCreds$rotate()

###Should I embedd this as well? Can go ahead and rotate is MFA token isn't necessary...
```

awsRestRequest is a generic function for AWS Rest-ful API requests, but the default parameters are setup to GET an object from S3. Test this out by pulling a file from S3 (in the data-science account).

```R
exFile <- awsRestRequest(
    credentials = awsCreds,
    bucketName = 'datasets.elasticmapreduce',
    path = 'hc_metadata/2017/04/17/00/hc_metadata_2017-04-17_00-25-28_ce55ff92-2306-11e7-a536-0aa367d0d639_ef4ac2fc-c679-4232-9861-c7038efe1e3e.json.log.gz'
)

s3://datasets.elasticmapreduce/ngrams/books/
s3://datasets.elasticmapreduce/ngrams/books/20090715/chinese/1gram/data

#This returns a raw object with a bunch of binary data
#  if no conversion function was passed.
#Converting in-memory isn't a huge problem,
#  but there are a handful of function in the package
#  to make it simpler for formats we commonly see.
exData <- streamJsonGZ(exFile)

#To save yourself some trouble, system memory,
#  and boilerplate pass your conversion function to awsRestRequest:
exData <- awsRestRequest(
    credentials = awsCreds,
    bucketName = 'dev-ds-lxk-psm-argus-datalogs-field',
    path = 'hc_metadata/2017/04/17/00/hc_metadata_2017-04-17_00-25-28_ce55ff92-2306-11e7-a536-0aa367d0d639_ef4ac2fc-c679-4232-9861-c7038efe1e3e.json.log.gz',
    conversionFUN = streamJsonGZ
)
```