#' @title getProfiles
#' @description Find profile files, parse, and return combined credential/config profiles.
#' @param prefix (string) the path to where credential/config files are stored
#' @param credentialFileName (string) the arg name pretty much says it
#' @param configFileName (string) the arg name pretty much says it
#' 
#' @details
#' If no prefix is provided, attempts to identify the default path given the OS detacted.  
#' The default parameters should be sufficient unless you have customized the credential/config files.
#' It is assumed your credentials file follows the guidelines at:
#' [AWS CLI Configuration and Credential Files'](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)
#'
#' @examples
#' getProfiles(
#'     prefix = '/path/to/files',
#'     credentialFileName = 'specialNameCredentials',
#'     configFileName = 'specialNameConfig'
#' )
#'
#' Maybe you don't have a config file, below processes the credential file and prints a soft warning about missing config.
#' getProfiles(configFileName = NULL)
#'
#' @export
getProfiles <- function(prefix = NULL, credentialFileName = NULL, configFileName = NULL, profileName = NULL) {
    if (is.null(credentialFileName)){
        credentialFileName <- 'credentials'
    }
    
    if (is.null(configFileName)){
        configFileName <- 'config'
    }
    
    fileLocs <- genCredentialFilePath(prefix, credentialFileName, configFileName)
    #look in the search path for credentials and config files and read into structured lists.
    tmpInfo <- lapply(fileLocs, function(x){try(parseCredentialFile(x), silent = TRUE)})
    tmpInfo <- tmpInfo[sapply(tmpInfo, class) != 'try-error']
    
    if (length(tmpInfo) == 0)
        stop(sprintf('\n  Profile files not found at:\n\t%s\n\t%s\n', fileLocs[['credentialLoc']], fileLocs[['configLoc']]))
    
    if (!'configLoc' %in% names(tmpInfo)) {
        warning('\n  Config file not found. Continuing with credential file only.')
        return(tmpInfo[['credentialLoc']])
    }
    
    #If a config file is found, combine the profile settings with those found in the credentials file.
    for (config in names(tmpInfo[['configLoc']])) {
        if (!config %in% names(tmpInfo[['credentialLoc']])) { #no guarantee someone will have consistent profile names in config/credentials.
            tmpInfo[['credentialLoc']][[config]] <- list()
        }
        
        for (k in names(tmpInfo[['configLoc']][[config]])) {
            tmpInfo[['credentialLoc']][[config]][[k]] <- tmpInfo[['configLoc']][[config]][[k]]
        }
    }
    
    if (!is.null(profileName)) {
        tmpInfo[['credentialLoc']][names(tmpInfo[['credentialLoc']]) != profileName] <- NULL
    }
    
    return(tmpInfo[['credentialLoc']])
}