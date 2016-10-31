x <- content(callAction(sess, 'table.columnInfo', list(table='CLOUD-PRICING')))
keepers <- which(names(unlist(x$results$ColumnInfo$schema))=='name') 
res <- data.frame(t(apply(t(x$results$ColumnInfo$rows),2,FUN=unlist)))
colnames(res) <- c(t(unlist(x$results$ColumnInfo$schema)[keepers]))





x <- content(callAction(sess,'regression.glm',list(table='CLOUD-PRICING',model=list(depvar='Price',effects='mem'))))

x <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', 'regression.glm', sep='/'), 
     body=list(table='CLOUD-PRICING',model=list(depvar='Price',effects='mem')),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json'
     #,verbose()
     )