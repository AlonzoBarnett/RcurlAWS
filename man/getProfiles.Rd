% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/getProfiles.R
\name{getProfiles}
\alias{getProfiles}
\title{getProfiles}
\usage{
getProfiles(prefix = NULL, credentialFileName = NULL,
  configFileName = NULL, profileName = NULL)
}
\arguments{
\item{prefix}{(string) the path to where credential/config files are stored}

\item{credentialFileName}{(string) the arg name pretty much says it}

\item{configFileName}{(string) the arg name pretty much says it}
}
\description{
Find profile files, parse, and return combined credential/config profiles.
}
\details{
If no prefix is provided, attempts to identify the default path given the OS detacted.  
The default parameters should be sufficient unless you have customized the credential/config files.
It is assumed your credentials file follows the guidelines at:
[AWS CLI Configuration and Credential Files](https://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html)
}
\examples{
getProfiles(
    prefix = '/path/to/files',
    credentialFileName = 'specialNameCredentials',
    configFileName = 'specialNameConfig'
)

#Maybe you don't have a config file, below processes the credential file and prints a soft warning about missing config.
getProfiles(configFileName = NULL)

}
\seealso{
Other credential management functions: \code{\link{AWSRootCredentials}},
  \code{\link{AWSTemporaryCredentials}},
  \code{\link{RcurlAWS}},
  \code{\link{credsFromInstanceMetadata}},
  \code{\link{genCredentialFilePath}},
  \code{\link{getCredentials}},
  \code{\link{getSTSCredentials}},
  \code{\link{parseCredentialFile}},
  \code{\link{stsGenContentString}},
  \code{\link{tempCredentialHandler}}
}
\concept{credential management functions}
