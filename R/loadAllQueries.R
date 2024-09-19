loadAllQueries <- function(){
  if(exists('.queryLibrary', envir = .GlobalEnv) && exists('allQueries', envir = .queryLibrary)){
    return(get('allQueries', envir = .queryLibrary))
  }
  ret <- list()
  for (typ in c("Data load", 'General statistics')){
    ql <- system.file(paste0('QueryLibrary/',typ), package = 'queryLibrary')
    if(nchar(ql) == 0){
      next
    }
    ql <- paste0(ql, '/')
    lst <- dir(ql, no..=TRUE)
    if(length(lst) == 0){
      next
    }
    ret[[typ]]<- sapply( lst, function(domain){
    
        unlist(lapply(list.files(paste0(ql, domain), recursive = TRUE, no..=TRUE), function(x){
          fl <- paste0(ql, domain,'/', x)
          rt <-parseMd(fl)
          n <- rt$Name
          rt$Name <- NULL
          out <- list()
          out[[make.names(n)]] <- rt
          out
        }), recursive = FALSE)
    }, simplify = FALSE)
  
  }
  assign('.queryLibrary',new.env(parent=.GlobalEnv), envir = .GlobalEnv)

  assign('allQueries', ret, envir = .queryLibrary)
  ret
}
