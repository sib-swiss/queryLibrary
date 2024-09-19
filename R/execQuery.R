#' @title Load the result of an OMOP query.
#' @description Load the resuults of one of the preset queries (previously retrieved with showQueries)
#' @param domain a character, the query domain (ex. 'care_site')
#' @param query_name the query name as it appears in the result of showQueries
#' @param input a vector of input parameters, in the same order as they appear in the text of the query. Information is available in showQueries() for each case.
#' @param where_clause an optional where clause that can be appended to the query (without the 'where' keyword)
#' @param row_limit maximum number of rows retrieved
#' @param db_connection a character, the name of the connection to the database. It must already exist in the R session.
#' If no db_connection is provided, the first connection found in the session will be used. 
#' @param cdm_schema a character, the name of the data schema (default 'public')
#' @param vocabulary_schema a character, the name of the vocabulary schena (default 'public')
#' @return a data frame containing the query result
#' @export
execQuery <- function ( domain = NULL, query_name = NULL, input = NULL, where_clause = NULL, row_limit = NULL, row_offset = 0, db_connection = NULL, cdm_schema = 'public', vocabulary_schema =' public'){
    myEnv <- parent.frame()
    allq <- tryCatch(get('allQueries', envir = .queryLibrary), error = function(e){
      loadAllQueries()
    })
    for (typ in c( 'Data load','General statistics')){
      qList <- allq[[typ]][[domain]]
      if(!is.null(qList)){
        break
      }
    }
    realquery_nameCandidates <- grep(query_name, names(qList), value = TRUE)
    if(length(realquery_nameCandidates) > 1){ # if more than one look for the exact match
      realquery_name <- grep(paste0('^', query_name, '$'), realquery_nameCandidates, value = TRUE)[1] 
    } else {
      realquery_name <- realquery_nameCandidates[1]
    }
    
    if(is.null(realquery_name)){
      stop(paste0('No such query name: ', query_name, ' or domain: ', domain, '.'), call. = FALSE)
    }
    myQuery <- paste(qList[[realquery_name]]$Query, collapse = ' ')
    if(is.null(db_connection)){
      for (i in ls(envir = .GlobalEnv)){
        x <- get(i, envir = .GlobalEnv)
        if("PqConnection" %in% class(x)){
          db_connection <- x
          break
        }
      }
    }
    if(is.null(db_connection)){ # still
      stop('Could not find a suitable database connection.')
    } 
    
    
    
    myQuery <- gsub('@cdm', cdm_schema, myQuery, fixed = TRUE)
    myQuery <- gsub('@vocab', vocabulary_schema, myQuery, fixed = TRUE)
    
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
  # get rid of the semicolon at the end if any:
    myQuery <- sub(';\\s*$','',myQuery)
    # add the filter and limit
  if(!is.null(where_clause)){
    myQuery <- paste0('select * from (', myQuery,  ') xyx where ', where_clause)
  }
  if(!is.null(row_offset)){
      myQuery <- paste0(myQuery, ' offset ', row_offset)
  } 
      
  if(!is.null(row_limit)){
      myQuery <- paste0(myQuery,  ' limit ', row_limit)
  }
    
     return(DBI::dbGetQuery(db_connection, myQuery, params = input))

  }
  