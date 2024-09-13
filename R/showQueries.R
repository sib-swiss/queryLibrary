#' @title  Show all available queries 
#' @description Return all the available queries explained and grouped by domain.
#' @param query_type a character, one of "General statistics" or "Data load". General statistics: generic statistics queries, same as the ones provided by the QueryLibrary OHDSI app.
#' Data load: queries that load data in the R session, preformatted for further processing.
#' @param domain a character, used to restrict the retrieved queries by domain (a list of all available domains is shown when invoking with domain = NULL)
#' @param query_name a character, restricts  the result to one specific query
#' @return a list containing all the available queries with documentation
#' @export
showQueries <- function (query_type = c("General statistics", "Data load"),domain = NULL, query_name = NULL){

  if(!exists('.queryCache', where = .GlobalEnv)){
    myexpr <- paste0('')
    # run only on one datasource:
    queryList <- loadAllQueries()
    newfunc <- function(query_type = c("General statistics", "Data load"), domain = NULL, query_name = NULL){
      return(.readQueryList(query_type,queryList, domain, query_name, datasources))
    }
    assign('.queryCache', newfunc, envir = parent.frame())
    return(.readQueryList(query_type, queryList, domain, query_name))
  } else {
    return(.queryCache(query_type, domain, query_name))
  }
  
}


.readQueryList <- function(qType, queryList, domain= NULL, query_name = NULL){

  if(is.null(qType) || length(qType) > 1){
    qType <- select.list(names(queryList), title = 'General statistics; Simplified data loading')
    if(qType==''){
      return()
    }

    return(.readQueryList(qType, queryList, domain, query_name))
  }
  
  if(is.null(domain)){
    domain <- select.list(names(queryList[[qType]]), title = 'Query domain (0 to exit)')
    if(domain==''){
      return()
    }
    return(.readQueryList(qType, queryList, domain, query_name))
  }
  if(is.null(query_name)){
    query_name <- select.list(names(queryList[[qType]][[domain]]), title = 'Available queries(0 to go back)') 
    if(query_name==''){
      return(.readQueryList(qType,queryList))
    } else (
      return(.readQueryList(qType, queryList, domain, query_name))
    )
  }

  sapply(names(queryList[[qType]][[domain]][[query_name]]), function(x){
    cat(paste0(x, ': '), sep="\n")
    if(x %in% c('Query', 'Description')){
      cat(queryList[[qType]][[domain]][[query_name]][[x]], sep = "\n")
    } else {
      print(queryList[[qType]][[domain]][[query_name]][[x]])
    }
    cat("\n")
  })
  run <-  select.list(c('yes', 'no'), title = 'Do you want to run it in the database?')
  if(run=='yes'){

    input <- NULL
    parms <-  queryList[[qType]][[domain]][[query_name]]$Input
    if(!is.vector(parms) || !grepl('none', parms, ignore.case = TRUE)){
      cat("This query has the folowing parameters:", "\n")
      print(format(parms))

      input <-unlist(lapply(parms$Parameter, function(x) readline(paste0('Value for "', x, '": '))))

    }
    lim <- readline('Please enter the desired row limit here (press return for all rows):')
    if(lim == ''){
        lim <- NULL
    }
    execQuery(domain,query_name, input,NULL, lim )
    
  }
}



