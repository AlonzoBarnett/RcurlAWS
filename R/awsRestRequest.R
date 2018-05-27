#'Need to add useful documentation...
#'Generic function to submit an API request.
#'Your credentials should be an object of class AWSRootCredentials or AWSTemporaryCredentials.
#'Temporary credential expiration is handled prior to configuring an API request by calling rotate() method.
#'How API query requests work:
#'http://docs.aws.amazon.com/AWSEC2/latest/APIReference/Query-Requests.html
#' @export
awsRestRequest <- function(
        credentials,
        httpMethod = "GET",
        protocol = "https",
        service = "s3",
        host = "amazonaws.com",
        path = NULL,
        optionalParams = NULL,
        optionalHeaders = NULL,
        content = NULL,
        conversionFUN = NULL
	) {
    
    if (!isCredClass(credentials)) {
        stop("\"credentials\" must be class of AWS(Root|Temporary)Credentials.")
    }
    
    if (isTempCred(credentials)) {
        if (credentials$hasExpired()) {
            credentials$rotate()
        }
    }
    
    internalURI <- paste0(
        protocol,
        "://",
		service,
        ".",
        host,
        ifelse(is.null(path), "/", sprintf("/%s", path)),
        if (!is.null(optionalParams)) sprintf("?%s",  paste(paste0(names(optionalParams), "=", optionalParams), collapse = "&"))
	)
	
	headers <- authorization(
        credentials = credentials, httpMethod = httpMethod,
        host = host, path = path, service = service, headers = optionalHeaders,
        content = content, queryParameters = optionalParams
    )
	
    h <- curl::new_handle()
    
    curl::handle_setheaders(h, .list = headers)
    
    if (httpMethod == 'POST') {
        curl::handle_setopt(h, customrequest = "POST", postfields = content)
    }
    
    rez <- curl::curl_fetch_memory(url = URLencode(internalURI), handle = h)
    
	if (is.null(conversionFUN))
        return(rez$content)
	
	return(conversionFUN(rawToChar(rez$content)))
}