get '/register' do
   haml :register
end

post '/register' do
   new_user = Rose::User.first_or_create(:username => params[:username], :password => params[:password])
   new_user.save
   fork { new_user.scrape }
   
   login_user new_user
   redirect '/'
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

