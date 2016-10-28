library(httr)
library(jsonlite)
source('CASFunctions.R')

hostname <- 'racesx12103.demo.sas.com:8777'
server <- 'cas-shared-default'              # CAS server name
uri.token <- 'SASLogon/oath/token'
uri.casManagement <- 'casManagement/servers'
uri.casProxy <- 'casProxy/servers'
# Get basic environment info
GET(paste(hostname, 'cas', sep='/'), authenticate('viyauser','Orion123'))

r <- GET(paste(hostname, 'grid', sep='/'), authenticate('sasdemo','Orion123'))

lapply(content(r), function(x) { paste(x$name, x$type, sep=' - ')})

# Create a session and store the id
sess <- content(POST(paste(hostname, 'cas', 'sessions', sep='/'), authenticate('viyauser','Orion123')))$session
print(sess)

r <- content(callAction(sess, 'table.tableInfo', list(caslib='CASUSER')))
t(apply(t(r$results$TableInfo$rows),2,FUN=unlist))


uploadCAScsv(sess,'caslib','auto_policy','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')
uploadCAScsv(sess,'caslib','bank-additional-full','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')
uploadCAScsv(sess,'caslib','cloud-pricing','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')

getTableInfo(sess, 'CASUSER')



# THIS IS A TEST BLOCK - DELETE WHEN ALL DONE Specify action parameters
params <- '{"casout": {"caslib": "casuser", "name": "cloud-pricing"}, "importOptions": {"fileType": "CSV"} }'

# Store the start time
start <- proc.time()

r <- PUT(paste(hostname, 'cas', 'sessions', sess, 'actions', 'table.upload', sep='/'),
         body=upload_file('/home/viyauser/SamsViya/JupyterDemos_JW/data/cloud-pricing.csv'),
         authenticate('viyauser','Orion123'),
         add_headers('JSON-Parameters'=params, 'Content-Type'='binary/octet-stream'),
         verbose()
)

r
