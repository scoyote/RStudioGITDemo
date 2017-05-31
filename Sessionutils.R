library(httr)
library(jsonlite)

hostname <- 'xxx:8777'
casusr <- 'cas'
viyauser <- 'xxx'
pwd <- 'xxx'




POST(paste(hostname, 'cas', 'sessions',sep='/'), authenticate(viyauser,pwd))
