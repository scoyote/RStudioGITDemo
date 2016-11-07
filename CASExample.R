library(httr)
library(jsonlite)
library(reshape)
source('CASFunctions.R')


hostname <- 'racesx12101.demo.sas.com:8777'
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


uploadCAScsv(sess,'caslib','auto_policy','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')
uploadCAScsv(sess,'caslib','bank-additional-full','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')
uploadCAScsv(sess,'caslib','cloud-pricing','C:\\Users\\sacrok\\OneDrive\\SAS\\JupyterDemos_JW\\data\\','viyauser','Orion123')

getTableInfo(sess, 'CASUSER')

# Drop Table
# content(callAction(sess,'table.dropTable',list(caslib='CASUSER', name='CLOUD-PRICING')))



getTableInfo(sess, 'CASUSER')
getColumnInfo(sess, 'CLOUD-PRICING')

# Load the Regresssion Actionset
content(callAction(sess,'loadactionset',list(actionset='regression')))

#    s.regression.glm(
#      table='analysisData',  
#      classVars=['c1','c2','c3'], 
#      model={ 'depVar':'y', 
#        'effects':['c1','c2','c3','x1','x2','x3']
#      }
#    ) 

#run the regression
reg.fit <- content(callAction(sess,'regression.glm',list(table='CLOUD-PRICING',model=list(depvar='Price',effects=list('mem','vcpu')))))

getParameterEstimates(reg.fit)
getModelInfo(reg.fit)
getFitStatistics(reg.fit)


reg2.fit <- content(callAction(sess,'regression.glm',list(table='CLOUD-PRICING',classVars=list('Provider'),model=list(depvar='Price',effects=list('Provider','mem','vcpu')))))

#Print out the results 
getParameterEstimatesClass(reg2.fit)
getModelInfo(reg2.fit)
getFitStatistics(reg2.fit)


