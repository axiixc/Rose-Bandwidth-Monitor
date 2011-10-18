get '/profile/:token' do |token|
   @profile_user = @session_user.username == token ? @session_user : Rose::User.first(:username => token, :public_stats => true)
   @profile_user = Rose::User.first(:protected_stats_token => token) if @profile_user.nil?
   if @profile_user.nil?
      return "Invalid user profile"
   else
      haml :profile
   end
end

get '/profile/?' do
   redirect '/'
end

get '/userlist' do
   haml :userlist
end