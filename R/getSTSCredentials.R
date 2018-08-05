#'The structure of an STS request and response is fully described at:
#'http://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
#'
#' @family credential management functions
#' @family service wrappers
getSTSCredentials <- function(rootCredentials = NULL, roleArn = NULL, RoleSessionName = NULL, MFADeviceSerialNumber = NULL, Duration = "3600") {
    
    stsContent <- stsGenContentString(
        roleArn = roleArn, RoleSessionName = RoleSessionName,
        MFADeviceSerialNumber = MFADeviceSerialNumber,
        Duration = Duration
    )

    startTime <- as.POSIXlt(Sys.time(), tz = "GMT")
    tmpcreds <- awsRestRequest(
        credentials = rootCredentials, httpMethod = "POST", service = "sts",
        optionalHeaders = c("content-type" = "application/x-www-form-urlencoded; charset=utf-8"),
        content = stsContent, conversionFUN = XML::xmlToList
    )
    
    tmpcreds <- tmpcreds$AssumeRoleResult$Credentials
    names(tmpcreds)[grep("^access", names(tmpcreds), ignore.case = T)] <- "AWS_ACCESS_KEY_ID"
    names(tmpcreds)[grep("^secret", names(tmpcreds), ignore.case = T)] <- "AWS_SECRET_ACCESS_KEY"
    names(tmpcreds)[grep("token$", names(tmpcreds), ignore.case = T)] <- "Token"
    
    tmpcreds$Expiration <- as.POSIXlt(tmpcreds$Expiration, tz = "GMT", format = "%Y-%m-%dT%H:%M:%S")
    
    return(c(list(LastUpdated = startTime), tmpcreds))
}
