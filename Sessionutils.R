library(httr)
library(jsonlite)

hostname <- 'racesx07055.demo.sas.com:8777'
casusr <- 'cas'
viyauser <- 'viyauser'
pwd <- 'Orion123'




POST(paste(hostname, 'cas', 'sessions',sep='/'), authenticate(viyauser,pwd))