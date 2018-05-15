#'Uses curl to pull EC2 instance metadata which contains access, secret,
#'    and token for the Instance Role... not using a role, shame on you.
credsFromInstanceMetadata <- function() {
    #Get the IAM of the instance
    instRoleResponse <- curl::curl_fetch_memory("http://169.254.169.254/latest/meta-data/iam/security-credentials/")
    instRole <- rawToChar(instRoleResponse[['content']])
    #Now get the credentials of the instance.
    instCredResponse <- curl::curl_fetch_memory(sprintf("http://169.254.169.254/latest/meta-data/iam/security-credentials/%s", instRole))
    tmpCreds <- rawToChar(instCredResponse[['content']])
    tmpCreds <- rjson::fromJSON(tmpCreds, method = "C")
    
    #Convert DTTM to R classes.
    tmpCreds$LastUpdated <- as.POSIXlt(tmpCreds$LastUpdated, tz = "GMT", format = "%Y-%m-%dT%H:%M:%S")
    tmpCreds$Expiration <- as.POSIXlt(tmpCreds$Expiration, tz = "GMT", format = "%Y-%m-%dT%H:%M:%S") 
    
    #Standardize the key names to those used in every other AWS schema.
    names(tmpCreds)[match(c("AccessKeyId", "SecretAccessKey"), names(tmpCreds))] <- c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY")
    
    return(tmpCreds)
}