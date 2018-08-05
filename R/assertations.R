isRootCred <- function(obj){return(any(class(obj) == 'AWSRootCredentials'))}
isTempCred <- function(obj){return(any(class(obj) == 'AWSTemporaryCredentials'))}
isCredClass <- function(obj){return(isRootCred(obj) | isTempCred(obj))}