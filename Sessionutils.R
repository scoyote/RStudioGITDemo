
usr <- 'cas'

getSessions(sess_c,'cas','Orion123')


x <- POST(paste(hostname, 'cas', 'sessions', sess_c, 'actions', "accesscontrol.listacsdata", sep='/'), 
     body=list(caslib='ViyaScor',listtype='direct'),
     authenticate('cas',pwd),
     content_type('application/json'),
     accept_json(),
     encode='json',
     verbose())