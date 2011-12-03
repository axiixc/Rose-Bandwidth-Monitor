get '/register' do
   haml :register
end

post '/register' do
   new_user = Rose::User.new(:username => params[:username], :password => params[:password])
   new_user.scrape
   
   if new_user.last_status_code != "200"
      @invalid_registration = true
      haml :register
   else
      new_user.save
      login_user new_user
      
      redirect '/'
   end
end

get '/login' do
   haml :login
end

get '/logout' do
   logout_user
   
   redirect '/'
end

post '/login/?' do
   pwhash = Rose::User.hash_password params[:password]
   
   if (not password_doesnt_match_user?(params[:username], pwhash))
      login_user Rose::User.first(:username => params[:username], :pwhash => pwhash)
      
      redirect '/'
   else
      @bad_login = true
      haml :login
   end
end

