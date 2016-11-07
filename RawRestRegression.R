library(httr)
library(jsonlite)

hostname <- 'racesx12101.demo.sas.com:8777'
server <- 'cas-shared-default'              # CAS server name
uri.token <- 'SASLogon/oath/token'
uri.casManagement <- 'casManagement/servers'
uri.casProxy <- 'casProxy/servers'
usr <- 'viyauser'
pwd <- 'Orion123'

# Create new session
sess <- content(POST(paste(hostname, 'cas', 'sessions', sep='/'), authenticate(usr,pwd)))$session

#load the SAS actionset
POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "loadactionset", sep='/'), 
          body=list(actionset='table'),
          authenticate('viyauser','Orion123'),
          content_type('application/json'),
          accept_json(),
          encode='json',
          verbose())

# Upload file
filepath <- 'C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\'
filename <- 'CLOUD-PRICING'
params <- paste('{"casout": {"caslib": "casuser", "name":"', filename,'"}, "importOptions": {"fileType": "CSV"} }',sep='')
print(params)

PUT(paste(hostname, 'cas', 'sessions', sess, 'actions', 'table.upload', sep='/'),
    body=upload_file(paste(filepath,filename,'.csv',sep='')),
    authenticate(usr,pwd),
    add_headers('JSON-Parameters'=params, 'Content-Type'='binary/octet-stream')
)

# Take a look at the tables loaded into CAS

t.info <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "table.tableInfo", sep='/'), 
               body=list(caslib='CASUSER'),
               authenticate(usr,pwd),
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


# Simple Linear Regression

#load the SAS actionset
POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "loadactionset", sep='/'), 
     body=list(actionset='regression'),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

reg.results <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', 'regression.glm', sep='/'), 
                    body=list(table='CLOUD-PRICING',model=list(depvar='Price',effects='mem')),
                    authenticate(usr,pwd),
                    content_type('application/json'),
                    accept_json(),
                    encode='json'
                    #,verbose()
)



###########################################################################################
# SVM
###########################################################################################

#load the SAS actionset
POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "loadactionset", sep='/'), 
     body=list(actionset='svm'),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())

svm.results <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', 'svm.svmTrain', sep='/'), 
                    body=list(table='CLOUD-PRICING',target='Provider',inputs=list('mem','Price'),savestate=list(name='SVMSave')),
                    authenticate(usr,pwd),
                    content_type('application/json'),
                    accept_json(),
                    encode='json'
                    #,verbose()
)

#####NNOT WORKING YET############
#load the SAS actionset for storing
POST(paste(hostname, 'cas', 'sessions', sess, 'actions', "aStore", sep='/'), 
     body=list(rstore='describe'),
     authenticate('viyauser','Orion123'),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())



aStore.results <- POST(paste(hostname, 'cas', 'sessions', sess, 'actions', 'aStore', sep='/'), 
                    body=list(table='CLOUD-PRICING',model=list(depvar='Price',effects='mem')),
                    authenticate(usr,pwd),
                    content_type('application/json'),
                    accept_json(),
                    encode='json'
                    #,verbose()
)


write(x = as.character(reg.results),file='reg_results.json')
