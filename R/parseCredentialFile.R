#' This isn't a super robust file parser, but will work well if AWS credential|config file guidelines are followed.
#' read lines of the credential or config file then iterate over forming a list of profiles.
#'
parseCredentialFile <- function(filePath = NULL) {
    tmpFile <- readLines(filePath, warn = F)
    profiles <- list()
    
    for (currentLine in tmpFile){
        if (!grepl('[[:alnum:]]', currentLine)){
            next
        }
        
        if (grepl("^\\[", currentLine)) {
            currentProfile <- trimws(gsub("\\[|\\]|profile", "", currentLine, ignore.case = TRUE))
            profiles[[currentProfile]] <- list()
            next
        } else {
            tmpPair <- sapply(strsplit(currentLine, '='), trimws)
            profiles[[currentProfile]][[toupper(tmpPair[1])]] = tmpPair[2]
        }
    }
    
    return(profiles)
}
