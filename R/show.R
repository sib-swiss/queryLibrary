showDomains <- function(){
  dir('inst/QueryLibrary/', no..=TRUE)
}

showDomainQueries <- function(domain){
  sapply(list.files(paste0('inst/QueryLibrary/', domain), recursive = TRUE, no..=TRUE), function(x){
        fl <- paste0('inst/QueryLibrary/', domain,'/', x)
        ret <-parseMd(fl)
        n <- ret$Name
        ret$Name <- NULL
        out <- list()
        out[[make.names(n)]] <- ret
        out
  })
  }
