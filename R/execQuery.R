execQuery <- function(qDomain , qName, qInput, symbol = NULL, rowFilter = NULL, rowLimit = NULL, rowOffset = 0, resource = NULL, union = TRUE, excludeColRegexes = NULL){
 myEnv <- parent.frame()  

  

 allq <- tryCatch(get('allQueries', envir = .queryLibrary), error = function(e){
                     loadAllQueries()
                  })
  for (typ in c('Assign', 'Aggregate')){
    qList <- allq[[typ]][[qDomain]]
    if(!is.null(qList)){
      break
    }
  }
  realQnameCandidates <- grep(qName, names(qList), value = TRUE)
  if(length(realQnameCandidates) > 1){ # if more than one look for the exact match
    realQname <- grep(paste0('^', qName, '$'), realQnameCandidates, value = TRUE)[1] 
  } else {
    realQname <- realQnameCandidates[1]
  }
  
  if(is.null(realQname)){
    stop(paste0('No such query name: ', qName, ' or domain: ', qDomain, '.'), call. = FALSE)
  }
  myQuery <- paste(qList[[realQname]]$Query, collapse = ' ')

  qInput <- dsSwissKnife:::.decode.arg(qInput)
  if(is.null(resource)){
    resource <- c()
    for (i in ls(envir = myEnv)){
      x <- get(i, envir = myEnv)
      if("SQLFlexClient" %in% class(x)){
        resource <- c(resource, i)
      }
    }
  }
  if(is.null(resource)){ # still
    stop('Could not find a suitable database connection.')
  } else {
    resource <- dsSwissKnife:::.decode.arg(resource)
  }

# must be set via option:
  myQuery <- gsub('@cdm', getOption('cdm_schema', default = 'public'), myQuery, fixed = TRUE)
  myQuery <- gsub('@vocab', getOption('vocabulary_schema', default = 'public'), myQuery, fixed = TRUE)
  #replace generic variables with options with the same name
  #this would replace @~some.variable~@ with getOption('some.variable):
  if (grepl('.*?@~(.*?)~@.*?', myQuery)){ ### variables apear like @~somevar~@
    vars <-gsub('.*?@~(.*?)~@.*?', '\\1#', myQuery) # list their names separated by #
    vars <- strsplit(vars, '#')[[1]] # make it a vector
    # Replace the vars one by one with their values found in the environment as options:
    myQuery <- Reduce(function(x,y){
                        gsub(paste0('@~',y, '~@'), getOption(y, default = ''), x, fixed = TRUE)
                      }, vars, init = myQuery)
  }
  #this would replace @~some.variable~@ with getOption('some.variable')
  # get rid of the semicolon at the and if any:
  myQuery <- sub(';\\s*$','',myQuery)
  # add the filter and limit
  rowFilter <- dsSwissKnife:::.decode.arg(rowFilter)
  if(!is.null(rowFilter) && typ == 'Assign'){
    # some basic sql injection defense:
    if(grepl('delete|drop|insert|truncate|update|;', rowFilter, ignore.case = TRUE)){
      stop('The filtering clause looks dangerous, not executing', call. = FALSE)
    }
    
    myQuery <- paste0('select * from (', myQuery,  ') xyx where ', rowFilter)
  }
  if(is.null(rowOffset)){
    rowOffset <- 0
  }
 # myQuery <- paste0(myQuery, ' offset ', rowOffset)
  if(typ == 'Assign'){
    if(!is.null(rowOffset)){
      myQuery <- paste0(myQuery, ' offset ', rowOffset)
    } 
  
    if(!is.null(rowLimit)){
       myQuery <- paste0(myQuery,  ' limit ', rowLimit)
    }
  }
  
  ret <- sapply(resource, function(x){
    out <- resourcex::qLoad(get(x, envir = myEnv), myQuery, params = qInput)
   }, simplify = FALSE)
  
  
  
  if(typ == 'Aggregate'){
  ret <- sapply(ret, function(x) .strip_sensitive_cols(qList[[realQname]][['Sensitive fields']], x), simplify = FALSE)
    return(ret)
  } # else it's Assign:
  if(is.null(symbol)){
    symbol <- realQname
  }
 if(!is.null(excludeColRegexes)){
   ret <- sapply(ret, function(x){
     x[, .trim_hidden_fields(colnames(x), excludeColRegexes),drop=FALSE]
   }, simplify = FALSE)
 }
  ret <- sapply(names(ret), function(x){
      if(NROW(ret[[x]]) > 0 ){
        ret[[x]]$database <- x
        ret[[x]]
      }
  }, simplify = FALSE)
    # rbind them all if so asked:
  if(union){
      mydf <-  Reduce(rbind, ret)
      mydf$database <- factor(mydf$database)
      assign(symbol, mydf,envir = myEnv)
    } else { # or not:
      sapply(names(ret), function(x){
        assign(paste0(symbol, '_', x), ret[[x]], envir = myEnv)
      })
    }

  

  return(TRUE)
}


.strip_sensitive_cols <- function(cols, df){
  you_must <- getOption('dsQueryLibrary.enforce_strict_privacy', default = TRUE)
  if(you_must && !is.null(cols)){
    lim <- getOption("datashield.privacyLevel", default = 5)
    for (mycol in cols){
      mycol <- gsub('\\s+', '', mycol)
      df[df[,mycol] < lim, mycol] <- NA
    }
    
  }
  return(df)
}

# helper function to avoid loading useless columns:
.trim_hidden_fields <- function(cols, regs){

  
  for (r in regs){
    cols <- grep(r, cols, value = TRUE, perl = TRUE, invert = TRUE)
  }
  cols
}

