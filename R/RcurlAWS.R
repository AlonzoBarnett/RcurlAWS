#' RcurlAWS: a package for R intended to facilitate use of AWS services without external dependencies.
#'
#' Primary development is around credential management (both root and STS), somewhat robust use of cerdential/config files, and generic API requests.  Aws Root and Temporary credential management implemented using R6 classes.  STS is supported to generate temporary credentials.
#'
#'Helper functions to access AWS services via package::curl  
#'
#' \itemize{
#'   \item limited functionality is implemented in wrappers which obscure the worker functions 
#'   \itemIn theroy any HTTP(S) style request to the AWS REST API is possible with awsRestRequest 
#'   \item NEED TO add service-level [S3, SQS, etc.] modules 
#'   \item NEED TO ensuring all settings in a config file are used in service calls 
#' }
#'
#' @docType package
#' @name RcurlAWS
#'
NULL