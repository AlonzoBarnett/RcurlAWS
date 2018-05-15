#' Helper function to generate the content (body) of a STS assume role request.
#' This is used to pass MFA device credentials along with the role tto assume in order to generate temporary credentials.
#' If a RoleSessionName is not specified, a session uuid is generated.
#'
stsGenContentString <- function(roleArn, RoleSessionName, MFADeviceSerialNumber, Duration) {
    
    if (is.null(roleArn))
        stop("To assume role requires roleArn and NULL provided.")
    if (is.null(RoleSessionName))
        RoleSessionName <-  sprintf("anonSession_%s", uuid::UUIDgenerate(FALSE))
    
    if (!is.null(MFADeviceSerialNumber)) {
        tokenCode <- readline("MFA Token:")
        
        if (tokenCode == "")
            stop("MFA token cannot be blank.")
    }
    
    contentString <- paste0(
        sprintf("Action=AssumeRole&RoleSessionName=%s&RoleArn=%s", RoleSessionName, roleArn),
	    if(!is.null(MFADeviceSerialNumber))sprintf("&SerialNumber=%s&TokenCode=%s", MFADeviceSerialNumber, tokenCode),
		sprintf("&DurationSeconds=%s&Version=2011-06-15", Duration))
    )
    
    return(contentString)
}
