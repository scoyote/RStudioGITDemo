
# Create new session
viyauser_session <- content(POST(paste(hostname, 'cas', 'sessions',sep='/'), authenticate(viyauser,pwd)))$session


resx <-  content(POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "builtins.userInfo", sep='/'), 
                  body=,
                  #authenticate('viyauser',pwd),
                  content_type('application/json'),
                  accept_json(),
                  encode='json',
                  verbose()
))


#look at libraries
clibinfox <- POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "table.caslibInfo", sep='/'), 
                 body=,
                 authenticate('viyauser',pwd),
                 content_type('application/json'),
                 accept_json(),
                 encode='json',
                 verbose()
)
#Get the column names
keepers <- which(names(unlist(content(clibinfox)$results$CASLibInfo$schema))=='name') 
# create the dataframe with the rows concenring table information
res <- data.frame(t(apply(t(content(clibinfox)$results$CASLibInfo$rows),2,FUN=unlist)))
#apply the column names
colnames(res) <- c(t(unlist(content(clibinfox)$results$CASLibInfo$schema)[keepers]))
#write out the dataframe
res

#load the SAS actionset
POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "loadactionset", sep='/'), 
     body=list(actionset='table'),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())


# Upload file
filepath <- 'C:\\Users\\sacrok\\Documents\\RStudioGITDemo\\data\\'
filename <- 'titanic_train'
params <- paste('{"casout": {"caslib": "TITANIC", "name":"', filename,'","promote":"True"}, "importOptions": {"fileType": "CSV"} }',sep='')
PUT(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'table.upload', sep='/'),
    body=upload_file(paste(filepath,filename,'.csv',sep='')),
    authenticate(usr,pwd),
    add_headers('JSON-Parameters'=params, 'Content-Type'='binary/octet-stream')
    )
# Take a look at the tables loaded into CAS

t.info <- POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "table.tableInfo", sep='/'), 
               body=list(caslib='TITANIC'),
               authenticate('viyauser',pwd),
               content_type('application/json'),
               accept_json(),
               encode='json',
               verbose())

# Format the json
#Get the column names
keepers <- which(names(unlist(content(t.info)$results$TableInfo$schema))=='name') 
# create the dataframe with the rows concenring table information
res <- data.frame(t(apply(t(content(t.info)$results$TableInfo$rows),2,FUN=unlist)))
#apply the column names
colnames(res) <- c(t(unlist(content(t.info)$results$TableInfo$schema)[keepers]))
#write out the dataframe
res

###########################################################################################
# SVM
###########################################################################################

#load the SAS actionset
POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "loadactionset", sep='/'), 
     body=list(actionset='decisionTree'),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'svm.svmTrain', sep='/'), 
                    body=list(table='TITANIC_TRAIN',target='Survived',inputs=list('Age','Sex'),nominals=list('Sex','Survived'),savestate=list(name='TitanicSVM',caslib='TITANIC'),output=list(casOut=list(caslib='TITANIC',promote='True'))),
                    authenticate(usr,pwd),
                    content_type('application/json'),
                    accept_json(),
                    encode='json'
                    #,verbose
                    )
############

#POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'table.promote', sep='/'), 
#     body=list(name='TITANICSVM'),
#     authenticate('viyauser','Orion123'),
#     content_type('application/json'),
#     accept_json(),
#     encode='json',
#     verbose())


POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'table.save', sep='/'), 
     body=list(name='TITANICSVMx', table=list(name="TITANICSVM")),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())
###########


POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'astore.score', sep='/'), 
                       body=list(table=list(caslib='TITANIC',name='TITANIC_TEST'),rstore=list(name='TITANICSVM'),out=list(caslib='TITANIC',name='TITANIC_Scored',promote='True')),
                       authenticate(usr,pwd),
                       content_type('application/json'),
                       accept_json(),
                       encode='json'
                       #,verbose()
)

scored.Titanic <- POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', 'table.fetch', sep='/'), 
                 body=list(table=list(caslib='TITANIC',name='TITANIC_SCORED'),to=500),
                 authenticate(usr,pwd),
                 content_type('application/json'),
                 accept_json(),
                 encode='json'
                 #,verbose()
)

# Format the json
keepers <- which(names(unlist(content(scored.Titanic)$results$Fetch$schema))=='name') 
#Get the column names
# create the dataframe with the rows concenring table information
res <- data.frame(t(apply(t(content(scored.Titanic)$results$Fetch$rows),2,FUN=unlist)))
#apply the column names
colnames(res) <- c(t(unlist(content(scored.Titanic)$results$Fetch$schema)[keepers]))
#write out the dataframe
write.csv(res,file='C:\\Users\\sacrok\\OneDrive\\saskaggletitanic.csv')

POST(paste(hostname, 'cas', 'sessions', viyauser_session, 'actions', "session.endSession", sep='/'), 
     body=,
     authenticate(usr,pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

