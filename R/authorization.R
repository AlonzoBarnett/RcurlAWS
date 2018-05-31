#'AWS request Authorization using Signature version 4 method.
#'Your credentials should be a list object with names of 'access' and 'secret'.
#'This function is not intended to be called directly; it is called by awsRestRequest
#'
#'AWS signature 4:
#'http://docs.aws.amazon.com/AmazonS3/latest/API/sig-v4-header-based-auth.html
#'
#' Will default to region 'us-east-1' if no 'REGION' found in discovered profile settings.
#'
#'@param httpMethod string Generic as described in https://www.tutorialspoint.com/http/http_methods.htm; actual methods are specific to the  AWS Rest API.
#'
authorization <- function(
		credentials, httpMethod = "GET",
		service = "s3", host = "amazonaws.com",
		path = NULL, queryParameters = NULL,
		content = NULL, headers = NULL
	) {
    
    if (!isCredClass(credentials)) {
        stop("\"credentials\" must be class of AWS(Root|Temporary)Credentials.")
    }
    
	region <- credentials[['profileSettings']][['REGION']]
	if (is.null(region)) {
		region <- 'us-east-1'
	}
    
    requestDTTM <- format(Sys.time(), tz = "UTC")
    canonicalURI <- ifelse(is.null(path), "/", URLencode(sprintf("/%s", path)))
	
	canonicalQueryString <- ""
	if (!is.null(queryParameters)) {
	    canonicalQueryString <- queryParameters
	    names(canonicalQueryString) <- sapply(names(canonicalQueryString), curl::curl_escape)
		canonicalQueryString <- sapply(canonicalQueryString, curl::curl_escape)
		canonicalQueryString <- canonicalQueryString[order(names(canonicalQueryString))]
		canonicalQueryString <- paste(paste0(names(canonicalQueryString), "=", canonicalQueryString), collapse = "&")
	}
    
	if (is.null(content)) {
	    hashedPayload <- digest::digest("", "sha256", FALSE)
	}else{
        hashedPayload <- digest::digest(content, "sha256", FALSE)
	}
    
	defaultHeaders <- c(
		host = paste(service, host, sep = "."),
	    "x-amz-content-sha256" = hashedPayload,
		"x-amz-date" = strftime(requestDTTM, "%Y%m%dT%H%M%SZ")
	)
    
    if (!is.null(credentials$Token)) {
        defaultHeaders['x-amz-security-token'] <- credentials$Token
    }
    
    if (!is.null(headers)) {
	    headers <- c(headers, defaultHeaders)
        names(headers) <- tolower(names(headers))
        canonicalHeaders <- headers[order(names(headers))]
		signedHeaders <- paste(names(canonicalHeaders), collapse = ";")
        canonicalHeaders <- paste(paste0(names(canonicalHeaders), ":", canonicalHeaders, "\n"), collapse = "")
    }else{
	    headers <- canonicalHeaders <- defaultHeaders
		signedHeaders <- paste(names(canonicalHeaders), collapse = ";")
		canonicalHeaders <- paste(paste0(names(canonicalHeaders), ":", canonicalHeaders, "\n"), collapse = "")
	}
	
    canonicalRequest <- paste(
		httpMethod, canonicalURI, canonicalQueryString,
		canonicalHeaders, signedHeaders, hashedPayload,
		sep = "\n"
	)
					 
    signatureScope <- paste(strftime(requestDTTM, "%Y%m%d"), region, service, "aws4_request", sep = "/")

	signatureStr <- paste(
		"AWS4-HMAC-SHA256",
	    strftime(requestDTTM, "%Y%m%dT%H%M%SZ"),
		signatureScope,
		digest::digest(canonicalRequest, "sha256", FALSE),
		sep = "\n"
	)
    
    sigKey <- digest::hmac(
        digest::hmac(
		    digest::hmac(
			    digest::hmac(
				    paste0("AWS4", credentials$AWS_SECRET_ACCESS_KEY),
					strftime(requestDTTM, "%Y%m%d"),
					algo = "sha256",
					raw = T
				),
				region,
				algo = "sha256",
				raw = T
			),
			service,
			algo = "sha256",
			raw = T
		),
		"aws4_request",
		algo = "sha256",
		raw = T
    )
    
    signature <- digest::hmac(sigKey, signatureStr, algo = "sha256")
    
    return(
		c(
			Authorization = sprintf(
				"AWS4-HMAC-SHA256 Credential=%s/%s,SignedHeaders=%s,Signature=%s",
	            credentials$AWS_ACCESS_KEY_ID,
				signatureScope,
				signedHeaders,
				signature
			),
			headers
		)
)
}