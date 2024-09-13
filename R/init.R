.init <- function(){
  .queryLibrary <<- new.env(parent=.GlobalEnv)
  loadAllQueries()
}