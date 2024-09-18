parseMd <- function(fpath){
  f <- readLines(fpath)
  processLine <- FALSE
  isQuery <- FALSE
  for (myLine in f){
    if(grepl('^# ', myLine)){
      listName <- sub('^# ','', myLine)
      ret <- list(Name = listName)
      elName <- sub('^# ','', myLine)
      elname <- gsub('"','', myLine)
      processLine <- TRUE
      next
    }
    if(!processLine){
      next
    }
    if(grepl('^## ', myLine)){
      elName <- sub('^## ','', myLine)
      elname <- gsub('"','', myLine)
      next
    }
    if (myLine == '```sql'){
      isQuery <- TRUE
      next
    }
    if (myLine == '```'){
      isQuery <- FALSE
      next
    }
  
    if(nchar(myLine) > 0  && !grepl('```|---', myLine)){
      if(elName=='Query' && isQuery){
        try(ret[[elName]] <- c(ret[[elName]], myLine))
      } else if(grepl('\\|', myLine)){
        myNewLine <- strsplit(myLine,'\\s*\\|\\s*')[[1]]
        suppressWarnings(try(ret[[elName]] <- as.data.frame(rbind(ret[[elName]], myNewLine), stringsAsFactors = FALSE, row.names=NULL)))
      } else if (elName!='Query') {
         try(ret[[elName]] <- c(ret[[elName]], myLine))
      }
    }
    
  
  }
  ret <- sapply(ret, function(x){
    if(is.data.frame(x)){
      x <- x[,-1, drop=FALSE]
      colnames(x) <- x[1,]
      x <- x[2:nrow(x),]
      rownames(x) <- NULL
    }  
    x
  }, simplify = FALSE)
  if(!('Input' %in% names(ret))){
    ret$Input <- 'None'
  }
  ret
}
