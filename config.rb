configure :production do
   Rose.setup_datamapper true
end

configure :development do
   Rose.setup_datamapper false
   Rose::User.all.each do |user|
      user.update :full_name => nil
   end
end

configure do
   enable :sessions
   
   EXCLUSIVE_PATHS = [ '/login', '/register' ]
   UNPROTECTED_PATHS = [ '/backdoor', '/userlist', '/profile' ] + EXCLUSIVE_PATHS
   
   # Clear all caches
   Dir['caches/reports/*'].each { |f| File::delete(f) }
end