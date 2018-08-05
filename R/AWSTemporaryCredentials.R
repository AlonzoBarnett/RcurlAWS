#' @title tempCredentialHandler
#' @description Initializes a call to STS or pulls instance meta data
#' @param rootCredentials (AWSRootCredentials) Your root credential object to feed STS calls
#' @param roleArn (string) the ARN of the role you want to assume
#' @param MFADeviceSerialNumber (string) The id number (serial | arn) of your MFA device.
#' @param Duration (string) Duration, in seconds, of the role session; controls time-to-expire of temporary credentials.
#'
#' @details
#' This function isn't intended to be called directly; it is a method of the AWSTemporaryCredentials class.  
#' Initializes a call to STS or pulls instance meta data.  
#'    Exactly which depends on the arguments you pass.  
#' \enumerate{
#'   \item If root credentials are passed, it will call STS.
#'       \itemize{
#'         \item Only the root credentials and roleArn are required.
#'         \item If you have an account with MFA, you must pass your MFA SN.
#'         \item This only works with Assume Role for now, thus the requirement of a roleARN.
#'       }
#'   \item Otherwise, it will try to curl instance metadata and get temporary credentials from there.
#' }
#'
#' For additional information on STS requests refer to [STS Requests](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html)
#'
#'@family credential management functions
#'
tempCredentialHandler <- function(rootCredentials = NULL, roleArn = NULL, MFADeviceSerialNumber = NULL, Duration = "3600") { 
    
    #If you are rotating credentials, this will just use what is stored within the object.   
    if (isRootCred(private$rootCredentials)) {
        tmpcreds <- getSTSCredentials(
            rootCredentials = private$rootCredentials,
            roleArn = private$roleArn,
            RoleSessionName = private$RoleSessionName,
            MFADeviceSerialNumber = private$MFADeviceSerialNumber,
            Duration = private$Duration
        )
    }
    
    #If you are initializing temporary credentials, this will use the parameters you pass for the STS call
    #    and store those parameters for future use. 
    if (isRootCred(rootCredentials)) {
        tmpcreds <- getSTSCredentials(
            rootCredentials = rootCredentials,
            roleArn = roleArn,
            RoleSessionName = sprintf(
                "%s_%s",
                rootCredentials$AWS_ACCESS_KEY_ID,
                format(Sys.time(), '%Y%m%d_%H%M%S')
            ),
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
            private$RoleSessionName <- sprintf(
                "%s_%s",
                rootCredentials$AWS_ACCESS_KEY_ID,
                format(Sys.time(), '%Y%m%d_%H%M%S')
            )
            private$MFADeviceSerialNumber <- MFADeviceSerialNumber
            private$Duration <- Duration
        }
    }
    
    #Means you didn't pass root keys to use for an STS call,
    #    assumes you must me using an Instance with IAM role.
    if (is.null(rootCredentials) & is.null(private$rootCredentials)) 
        tmpcreds <- credsFromInstanceMetadata()
    
    self$profileSettings <- rootCredentials[['profileSettings']]
    self$LastUpdated <- tmpcreds$LastUpdated
    self$AWS_ACCESS_KEY_ID <- tmpcreds$AWS_ACCESS_KEY_ID
    self$AWS_SECRET_ACCESS_KEY <- tmpcreds$AWS_SECRET_ACCESS_KEY
    self$Token <- tmpcreds$Token
    self$Expiration <- tmpcreds$Expiration
    
    self$print()
}

#'@title AWS Temporary Root Credential Manager
#'@description R6 implementation of AWS Temporary Credential searches and management
#'
#'\code{AWSTemporaryCredentials$new(
#'    rootCredentials = NULL,
#'    roleArn = NULL,
#'    RoleSessionName = NULL,
#'    MFADeviceSerialNumber = NULL,
#'    Duration = "3600"
#')}
#'
#'\code{AWSTemporaryCredentials$print()}
#'\code{AWSTemporaryCredentials$hasExpired()}
#'\code{AWSTemporaryCredentials$rotate()}
#'
#' @param rootCredentials (AWSRootCredentials) Your root credential object to feed STS calls
#' @param roleArn (string) the ARN of the role you want to assume
#' @param MFADeviceSerialNumber (string) The id number (serial | arn) of your MFA device.
#' @param Duration (string) Duration, in seconds, of the role session; controls time-to-expire of temporary credentials.
#'
#'@details
#' For additional information on STS requests refer to:  
#'    \url{https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_request.html}  
#' Initializes a call to STS or pulls instance meta data. Exactly which depends on the arguments you pass.  
#' \enumerate{
#'   \item If root credentials are passed, it will call STS.
#'       \itemize{
#'         \item Only the root credentials and roleArn are required.
#'         \item If you have an account with MFA, you must pass your MFA SN.
#'         \item This only works with Assume Role for now, thus the requirement of a roleARN.
#'       }
#'   \item Otherwise, it will try to curl instance metadata and get temporary credentials from there.
#' }
#'
#' \code{$print()} similar behavior to \code{\link{AWSRootCredentials}}
#' \code{$hasExpired()} boolean check of stale temporary credentials
#' \code{$rotate()} invokes the initilization function again, but should retain knowledge of Root Credentials if used.
#'
#'@family credential management functions

#' @export
AWSTemporaryCredentials <- R6::R6Class(
    "AWSTemporaryCredentials",
    public = list(
        profile = NULL,
        profileSettings = NULL,
        LastUpdated = NULL,
        AWS_ACCESS_KEY_ID = NULL,
        AWS_SECRET_ACCESS_KEY = NULL,
        Token = NULL,
        Expiration = NULL,
        initialize = tempCredentialHandler,
        hasExpired = function() {
            difftime(self$Expiration, Sys.time(), units = "mins") <= 0L
        },
        print = function(...) {
            printAccess <- substr(self$AWS_ACCESS_KEY_ID, 1, 4)
            printAccess <- paste0(c(printAccess, rep("*", 5L), "..."))
            printSecret <- substr(self$AWS_SECRET_ACCESS_KEY, 1, 4)
            printSecret <- paste0(c(printSecret, rep("*", 5L), "..."))
            printToken <- substr(self$Token, 1, 4)
            printToken <- paste0(c(printToken, rep("*", 5L), "..."))
            
            cat("<AWSTemporaryCredentials>\n\tAWS_ACCESS_KEY_ID = ",
                printAccess,
                "\n\tAWS_SECRET_ACCESS_KEY = ",
                printSecret,
                "\n\tToken = ",
                printToken,
                "\n  Generated at: ",
                strftime(self$LastUpdated, usetz = T),
                "\n  Expires in: ",
                round(difftime(self$Expiration, Sys.time(), units = "mins"), 1L),
                " minutes.\n", sep = "")
             invisible(self)
        },
        setSysEnv = function(verbose = TRUE) {
            Sys.setenv(AWS_ACCESS_KEY_ID = tmpCreds$AWS_ACCESS_KEY_ID,
                       AWS_SECRET_ACCESS_KEY = tmpCreds$AWS_SECRET_ACCESS_KEY,
                       AWS_SECURITY_TOKEN = tmpCreds$Token)
            if (verbose)
                print("Temporary Credentials set in system environment.")
            invisible(self)
        },
        rotate = tempCredentialHandler),
    private = list(
        rootCredentials = NULL,
        roleArn  = NULL,
        RoleSessionName = NULL,
        MFADeviceSerialNumber = NULL,
        Duration = NULL
    )
)
