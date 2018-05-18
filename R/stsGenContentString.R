#Need to add documentation...
getMFAToken <- function(){
    #based on:
    # https://stackoverflow.com/questions/16847621/get-data-out-of-a-tcltk-function

    if (!interactive()) {
       return(readLines(file("stdin"), n = 1L))
    }
    
    mfaToken <- tcltk::tclVar("")
    tt <- tcltk::tktoplevel()
    tcltk::tkwm.title(tt,"Input MFA Token")
    mfaToken.entry <- tcltk::tkentry(tt, textvariable=mfaToken)
    
    reset <- function() { tcltk::tclvalue(mfaToken)<-"" }
    reset.but <- tcltk::tkbutton(tt, text="Reset", command=reset)
    
    submit <- function() {
        mfaTokenRet <- as.character(tcltk::tclvalue(mfaToken))
        e <- parent.env(environment())
        e$mfaTokenRet <- mfaTokenRet
        tcltk::tkdestroy(tt)
    }
    
    submit.but <- tcltk::tkbutton(tt, text="submit", command=submit)
    
    tcltk::tkgrid(tcltk::tklabel(tt,text="MFA Token"), mfaToken.entry, pady = 10, padx =10)
    tcltk::tkgrid(submit.but, reset.but)
    
    tcltk::tkwait.window(tt)
    return(mfaTokenRet)
}


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
        tokenCode <- getMFAToken()
        
        if (tokenCode == "")
            stop("MFA token cannot be blank.")
    }
    
    contentString <- paste0(
        sprintf("Action=AssumeRole&RoleSessionName=%s&RoleArn=%s", RoleSessionName, roleArn),
	    if(!is.null(MFADeviceSerialNumber))sprintf("&SerialNumber=%s&TokenCode=%s", MFADeviceSerialNumber, tokenCode),
		sprintf("&DurationSeconds=%s&Version=2011-06-15", Duration)
    )
    
    return(contentString)
}
