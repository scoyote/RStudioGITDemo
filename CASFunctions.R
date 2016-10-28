# Define a function to extract data from the response and reform as a data frame
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


getTableInfo <- function(session.p,caslib.p){
  x <- content(callAction(session.p, 'table.tableInfo', list(caslib=caslib.p)))
  keepers <- which(names(unlist(x$results$TableInfo$schema))=='name') 
  res <- data.frame(t(apply(t(x$results$TableInfo$rows),2,FUN=unlist)))
  colnames(res) <- c(t(unlist(x$results$TableInfo$schema)[keepers]))
  return(res)
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
