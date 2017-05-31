library(httr)
library(jsonlite)

hostname <- 'xxx:8777'
usr <- 'xxx'
pwd <- 'xxx'

# Create new session
cas_user_session <- content(POST(paste(hostname, 'cas', 'sessions', sep='/'), authenticate('cas',pwd)))$session

#create a caslib for meeeeee
POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "table.addCaslib", sep='/'), 
     body=list(activeOnAdd=T,name="Titanic",createDirectory=T,dataSource=list(srcType='DEFAULT'),session=F,path='/home/cas/titanic'),
     authenticate('cas',pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

#open up the global library to everyone

POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "accesscontrol.updsomeacscaslib", sep='/'), 
     body=list(acs=list(list(caslib='Titanic',identity='sas',identitytype='Group',permtype='GRANT',permission='ReadInfo'))),
    authenticate('cas',pwd),
    content_type('application/json'),
    accept_json(),
    encode='json',
    verbose())
POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "accesscontrol.updsomeacscaslib", sep='/'), 
     body=list(acs=list(list(caslib='Titanic',identity='sas',identitytype='Group',permtype='GRANT',permission='Select'))),
     authenticate('cas',pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())
POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "accesscontrol.updsomeacscaslib", sep='/'), 
     body=list(acs=list(list(caslib='Titanic',identity='sas',identitytype='Group',permtype='GRANT',permission='Promote'))),
     authenticate('cas',pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

#look at libraries
clibinfo <- POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "table.caslibInfo", sep='/'), 
     body=list(srcType='ALL'),
     authenticate('cas',pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose()
)
#Get the column names
keepers <- which(names(unlist(content(clibinfo)$results$CASLibInfo$schema))=='name') 
# create the dataframe with the rows concenring table information
res <- data.frame(t(apply(t(content(clibinfo)$results$CASLibInfo$rows),2,FUN=unlist)))
#apply the column names
colnames(res) <- c(t(unlist(content(clibinfo)$results$CASLibInfo$schema)[keepers]))
#write out the dataframe
res

#load a dataset to be scored
filepath <- 'C:\\Users\\sacrok\\Documents\\RStudioGITDemo\\data\\'
filename <- 'titanic_test'
params <- paste('{"casout": {"caslib": "TITANIC", "name":"', filename,'","promote":"True"}, "importOptions": {"fileType": "CSV"} }',sep='')
PUT(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', 'table.upload', sep='/'),
    body=upload_file(paste(filepath,filename,'.csv',sep='')),
    authenticate('cas',pwd),
    add_headers('JSON-Parameters'=params, 'Content-Type'='binary/octet-stream')
)

t.info <- POST(paste(hostname, 'cas', 'sessions', cas_user_session, 'actions', "table.tableInfo", sep='/'), 
               body=list(caslib='TITANIC'),
               authenticate('cas',pwd),
               content_type('application/json'),
               accept_json(),
               encode='json',
               verbose())

# Format the json
#Get the column names
keepers3 <- which(names(unlist(content(t.info)$results$TableInfo$schema))=='name') 
# create the dataframe with the rows concenring table information
res3 <- data.frame(t(apply(t(content(t.info)$results$TableInfo$rows),2,FUN=unlist)))
#apply the column names
colnames(res3) <- c(t(unlist(content(t.info)$results$TableInfo$schema)[keepers3]))
#write out the dataframe
res3





