### RcurlAWSS3
RcurlAWS is a package for R intended to facilitate use of AWS services without external dependencies like the AWS CLI or another language's SDK.

Primary development is around credential management (both root and STS) and generic API requests.  Specific service wrappers use RcurlAWS and offer a simpler interface for leveraging AWS.

Aws Root and Temporary credential management implemented using R6 classes.  S3 request, S3 multihandle requests for async d/l, get requests are returned in-memory. Some c++ based functionality is used to speed up S3 Signaure4 authentication. STS is supported to generate temporary credentials.

Helper functions to access AWS services via Rcurl -> libcurl -> Rest API  
-This is under active development, limited functionality is currently implemented in wrappers which obscure the worker functions.  
-In theroy any HTTP(S) style request to the AWS REST API is possible with the worker functions.  
-I plan to add high-level functionality (via wrappers [eventually documented]) as I need.  

The package is useful for making API calls and returning result directly in R.  Aids in-memory processing of data and temporary credential generation.  This in turn helps with reproducability and interoperability since external dependencies are minimized.

If you just want to copy data to local files, I recommend using any one of the multitude of tools available to do that.

### Tutorial

RcurlAWS contains the typical R-style documentation, .Rd help files.  So if you are unsure what to do just type ?RcurlAWS.  The package is intended for high-throughput from S3 directly in R.  A generic wrapper to submit AWS Rest-ful requests is provided.  In addition, there are credential manager classes which facilitate use of STS with Root credentials.

