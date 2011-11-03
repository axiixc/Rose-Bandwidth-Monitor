get '/profile/:token' do |token|
   @profile_standalone_layout = true
   @profile_user = (!@session_user.nil? && @session_user.username == token) ? @session_user : Rose::User.first(:username => token, :public_stats => true)
   if @profile_user.nil?
      @profile_user = Rose::User.first(:protected_stats_token => token)
      @profile_using_api_token = true
   end
   
   haml :profile
end

get '/profile/?' do
   redirect '/'
end

get '/userlist' do
   haml :userlist
end