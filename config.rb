configure do
   enable :sessions
   
   Rose.setup_datamapper !!(ENV['RACK_ENV'] == :production)
   
   EXCLUSIVE_PATHS = [ '/login', '/register' ]
   UNPROTECTED_PATHS = [ '/backdoor', '/userlist', '/profile' ] + EXCLUSIVE_PATHS
end