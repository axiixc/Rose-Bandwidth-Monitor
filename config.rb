configure :production do
   Rose.setup_datamapper true
end

configure :development do
   Rose.setup_datamapper false
end

configure do
   enable :sessions
   
   EXCLUSIVE_PATHS = [ '/login', '/register' ]
   UNPROTECTED_PATHS = [ '/backdoor', '/userlist', '/profile' ] + EXCLUSIVE_PATHS
end