#'@title getCredentials
#'@description Worker function to find credentials in multiple search locations.
#'@param AWS_ACCESS_KEY_ID Your AWS root account access id
#'@param AWS_SECRET_ACCESS_KEY Your AWS root account secret key
#'@param sourceFile Location of credentials file ex. ~/.aws/.credential
#'@param profileName Name of the profile you wish to invoke
#'    'defualt' is used unless otherwise explicitly declared
#'@param .silent Doesn't do anything but is reserved to warning suppression or verbosity setting
#'
#'@details
#'The initializer function of AWSRootCredentials object.
#'
getCredentials <- function(
    AWS_ACCESS_KEY_ID = NULL,
    AWS_SECRET_ACCESS_KEY = NULL,
    profileName = NULL, #"default"
    credentialPrefix = NULL,
    credentialFileName = NULL,
    configFileName = NULL
) {
    
    #If explicit credentials passed, just use those.
    if (!is.null(AWS_ACCESS_KEY_ID) & !is.null(AWS_SECRET_ACCESS_KEY)) {
        self$AWS_ACCESS_KEY_ID <- AWS_ACCESS_KEY_ID
        self$AWS_SECRET_ACCESS_KEY <- AWS_SECRET_ACCESS_KEY
        return(NULL)
    }
    
    #If Profile provided, look for it...
    if (!is.null(profileName)) {
        awsProfiles <- getProfiles(credentialPrefix, credentialFileName, configFileName, profileName)
        if (is.null(awsProfiles)){
            stop(sprintf('Profile %s not found.'), profileName)
        }
        self$profile <- profileName
        self$profileSettings <- awsProfiles[[profileName]]
        self$AWS_ACCESS_KEY_ID <- awsProfiles[[profileName]][['AWS_ACCESS_KEY_ID']]
        self$AWS_SECRET_ACCESS_KEY <- awsProfiles[[profileName]][['AWS_SECRET_ACCESS_KEY']]
        return(NULL)
    }
    
    #If no arg so far, try env.
    creds <- Sys.getenv(x = c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"))
    if (any(creds == "")) {
        creds <- NULL
    }else{
        self$AWS_ACCESS_KEY_ID <- creds$AWS_ACCESS_KEY_ID
        self$AWS_SECRET_ACCESS_KEY <- creds$AWS_SECRET_ACCESS_KEY
        return(NULL)
    }
    
    #Finally, nothing passed and no env hit, so try default profile lookup.
    profileName <- 'default'
    awsProfiles <- getProfiles(credentialPrefix, credentialFileName, configFileName, profileName)
    if (is.null(awsProfiles)){
        stop('Credential search failed and no default profile found.')
    }
    
    self$profile <- profileName
    self$profileSettings <- awsProfiles[[profileName]]
    self$AWS_ACCESS_KEY_ID <- awsProfiles[[profileName]][['AWS_ACCESS_KEY_ID']]
    self$AWS_SECRET_ACCESS_KEY <- awsProfiles[[profileName]][['AWS_SECRET_ACCESS_KEY']]
    return(NULL)
}