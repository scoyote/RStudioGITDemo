bbn # Define a function to extract data from the response and reform as a data frame
createDataFrame <- function(r) {
  # Extract columns names
  header <- lapply(content(r)$results$Fetch$schema, function(x) { x$name })
  #nrows <- length(content(r)$results$Fetch$rows)
  
  # Combine lists into columns of a matrix
  x <- mapply(c, content(r)$results$Fetch$rows)
  
  # Transpose and convert to data frame
  x <- as.data.frame(t(x))
  names(x) <- header
  return(x)
}




# Helper function for calling CAS actions
callAction <- function(session, action, params, debug=FALSE) {
  #    start <- proc.time()
  
  r <- POST(paste(hostname, 'cas', 'sessions', session, 'actions', action, sep='/'), 
            body=params,
            authenticate('viyauser','Orion123'),
            content_type('application/json'),
            accept_json(),
            encode='json',
            verbose())
  
  if (debug == TRUE) {
    cat(jsonlite::prettify(rawToChar(r$request$options$postfields)))
  }
  #    print(proc.time() - start)
  return(r)
}

#not sure this one is necessary now, but leaving it for the time being - STC
uploadCAScsv <- function(session.p, caslib.p, filename, filepath,usr,pwd){
  
  # Specify action parameters
  params <- paste('{"casout": {"',caslib.p,'": "casuser", "name":"', filename,'"}, "importOptions": {"fileType": "CSV"} }',sep='')
  #print(params)
  
  r <- PUT(paste(hostname, 'cas', 'sessions', session.p, 'actions', 'table.upload', sep='/'),
           body=upload_file(paste(filepath,filename,'.csv',sep='')),
           authenticate(usr,pwd),
           add_headers('JSON-Parameters'=params, 'Content-Type'='binary/octet-stream')
  )
  return(r)
}

#brevity - could be abstracted further - you are going to see a trend here
getTableInfo <- function(session.p,caslib.p){
  x <- content(callAction(session.p, 'table.tableInfo', list(caslib=caslib.p)))
  keepers <- which(names(unlist(x$results$TableInfo$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$TableInfo$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$TableInfo$schema)[keepers]))
  return(res)
}

getColumnInfo <- function(session.p,tabnam){
  x <- content(callAction(session.p, 'table.ColumnInfo', list(table=tabnam)))
  keepers <- which(names(unlist(x$results$ColumnInfo$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$ColumnInfo$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$ColumnInfo$schema)[keepers]))
  return(res)
}

#format helpers - these can be abstracted further, but I am stopping with this for now
getParameterEstimates <- function(x){ 
  keepers <- which(names(unlist(x$results$ParameterEstimates$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$ParameterEstimates$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$ParameterEstimates$schema)[keepers]))
  return(res)
}

getParameterEstimatesClass <- function(x){
  keepers <- which(names(unlist(x$results$ParameterEstimates$schema))=='name') 
  ress <- apply(t(x$results$ParameterEstimates$rows),2,FUN=unlist)
  for(i in 1:length(ress)){
    ress[[i]] <- ress[[i]][1:8]
  }
  res <- t(data.frame(ress))
  row.names(res) <- NULL
  colnames(res) <- c(t(unlist(x$results$ParameterEstimates$schema)[keepers]))
  return(res)
}


getModelInfo <- function(x){ 
  keepers <- which(names(unlist(x$results$ModelInfo$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$ModelInfo$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$ModelInfo$schema)[keepers]))
  return(res)
}

getFitStatistics <- function(x){ 
  keepers <- which(names(unlist(x$results$FitStatistics$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$FitStatistics$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$FitStatistics$schema)[keepers]))
  return(res)
}


getSessions <- function(sess,username, passwd){
  sessinfo <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "session.listSessions", sep='/'), 
                   body=,
                   authenticate(username,passwd),
                   content_type('application/json'),
                   accept_json(),
                   encode='json',
                   verbose())
  
  #Get the column names
  x <- which(names(unlist(content(sessinfo)$results$Session$schema))=='name') 
  # create the dataframe with the rows concenring table information
  y <- data.frame(t(apply(t(content(sessinfo)$results$Session$rows),2,FUN=unlist)))
  #apply the column names
  colnames(y) <- c(t(unlist(content(sessinfo)$results$Session$schema)[x]))
  #write out the dataframe
  return(y)
}

closeSession <-  function(sess,username, passwd){
  x<-  POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "session.endSession", sep='/'), 
       body=,
       authenticate(username,passwd),
       content_type('application/json'),
       accept_json(),
       encode='json',
       verbose())
  return(x)
}



x <- content(POST(paste(hostname, 'cas', 'sessions', sess_b, 'actions', "table.fileInfo", sep='/'), 
                  body=list(path="%"),
                  authenticate('viyauser',pwd),
                  content_type('application/json'),
                  accept_json(),
                  encode='json',
                  verbose()))
#Get the column names
keepers <- which(names(unlist(x$results$FileInfo$schema))=='name') 
# create the dataframe with the rows concenring table information
res <- data.frame(t(apply(t(x$results$FileInfo$rows),2,FUN=unlist)))
#apply the column names
colnames(res) <- c(t(unlist(x$results$FileInfo$schema)[keepers]))
#write out the dataframe
res