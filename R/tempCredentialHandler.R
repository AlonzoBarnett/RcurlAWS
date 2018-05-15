#' @title tempCredentialHandler
#' @description Initializes a call to STS or pulls instance meta data
#' @param rootCredentials (AWSRootCredentials) Your root credential object to feed STS calls
#' @param roleArn (string) the ARN of the role you want to assume
#' @param roleSessionName (string) An identifier for the request; this can be used for user auditing on AWS.
#' @param MFADeviceSerialNumber (string) The id number (serial | arn) of your MFA device.
#' @param Duration (string) Duration, in seconds, of the role session; controls time-to-expire of temporary credentials.
#'
#' @details
#' This function isn't intended to be called directly; it is a method of the AWSTemporaryCredentials class.
#' Initializes a call to STS or pulls instance meta data.
#'    Exactly which depends on the arguments you pass.
#' 1. If root credentials are passed, it will call STS.
#'    - Only the root credentials and roleArn are required.
#'    - If you have an account with MFA, you must pass your MFA SN.
#'    - This only works with Assume Role for now, thus the requirement of a roleARN.
#'
#' 2. Otherwise, it will try to curl instance metadata and get temporary credentials from there.
#'
#' For additional information on STS requests refer to [STS Requests](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html)
#'
tempCredentialHandler <- function(rootCredentials = NULL, roleArn = NULL, roleSessionName = NULL, MFADeviceSerialNumber = NULL, Duration = "3600") { 
    
    #If you are rotating credentials, this will just use what is stored within the object.   
    if (class(private$rootCredentials)[1] == "AWSRootCredentials") {
        tmpcreds <- getSTSCredentials(
            rootCredentials = private$rootCredentials,
            roleArn = private$roleArn,
            roleSessionName = private$roleSessionName,
            MFADeviceSerialNumber = private$MFADeviceSerialNumber,
            Duration = private$Duration
        )
    }
    
    #If you are initializing temporary credentials, this will use the parameters you pass for the STS call
    #    and store those parameters for future use. 
    if (class(rootCredentials)[1] == "AWSRootCredentials") {
        tmpcreds <- getSTSCredentials(
            rootCredentials = rootCredentials,
            roleArn = roleArn,
            roleSessionName = roleSessionName,
            MFADeviceSerialNumber = MFADeviceSerialNumber,
            Duration = Duration
        )

        #Store the root credentials and required arguments passed to ease rotation calls to STS.
        if (is.null(private$rootCredentials)) {
            private$rootCredentials <- AWSRootCredentials$new(
                AWS_ACCESS_KEY_ID = rootCredentials$AWS_ACCESS_KEY_ID,
                AWS_SECRET_ACCESS_KEY = rootCredentials$AWS_SECRET_ACCESS_KEY
            )
            private$roleArn <- roleArn
            private$roleSessionName <- roleSessionName
            private$MFADeviceSerialNumber <- MFADeviceSerialNumber
            private$Duration <- Duration
        }
    }
    
    #Means you didn't pass root keys to use for an STS call,
    #    assumes you must me using an Instance with IAM role.
    if (is.null(rootCredentials) & is.null(private$rootCredentials)) 
        tmpcreds <- credsFromInstanceMetadata()
    
    self$LastUpdated <- tmpcreds$LastUpdated
    self$AWS_ACCESS_KEY_ID <- tmpcreds$AWS_ACCESS_KEY_ID
    self$AWS_SECRET_ACCESS_KEY <- tmpcreds$AWS_SECRET_ACCESS_KEY
    self$Token <- tmpcreds$Token
    self$Expiration <- tmpcreds$Expiration
    
    self$print()
}