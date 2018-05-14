#' @title genCredentialFilePath
#' @description Identify the full path to source credential/config files
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
#' genCredentialFilePath(
#'     prefix = '/path/to/files',
#'     credentialFileName = 'specialNameCredentials',
#'     configFileName = 'specialNameConfig'
#' )
#'
#' @export
genCredentialFilePath <- function(prefix = NULL, credentialFileName = 'credentials', configFileName = 'config') {
    #if no prefix passed, assume we should look in user home directory.
    if (is.null(prefix)) {
        if (.Platform[['OS.type']]=='windows') {
            prefix <- sprintf('%s\\.aws', Sys.getenv('USERPROFILE'))
        } else {
            prefix <- sprintf('%s/.aws', path.expand('~'))
        }
    }
    
    return (
        list(
            credentialLoc = sprintf('%s/%s', prefix, credentialFileName),
            configLoc = sprintf('%s/%s', prefix, configFileName)
        )
    )
}