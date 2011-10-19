require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'haml'
require 'date'
require 'json'


Dir['models/*'].each { |model| require './' + model }
Dir['routes/*'].each { |route| require './' + route }
Dir['notification_providers/*'].each { |provider| require './' + provider }

require './config'

helpers do
   def login_user(user = nil)
      user = Rose::User.first(:username => session[:username], :pwhash => session[:pwhash]) if user.nil?
      
      if not user.nil?
         session[:username] = user.username
         session[:pwhash] = user.pwhash
         @session_user = user
      end
   end
   
   def logout_user
      session[:username] = nil
      session[:pwhash] = nil
      @session_user = nil
   end
   
   def password_doesnt_match_user?(user = nil, pwhash = nil)
      Rose::User.all(:username => user, :pwhash => pwhash).empty? && Rose::User.all(:username => session[:username], :pwhash => session[:pwhash]).empty?
   end
   
   def unprotected_user_path?
      _request_path_in UNPROTECTED_PATHS
   end
   
   def exclusive_user_path?
      _request_path_in EXCLUSIVE_PATHS
   end
   
   def _request_path_in(paths)
      paths.each { |path| return true if request.path_info == path or request.path_info[0...path.size] == path }
      return false
   end
end

before do
   # If the user is not logged in only allow access to unprotected paths
   if password_doesnt_match_user?(params[:username], params[:pwhash]) && (not unprotected_user_path?)
      redirect '/login'
      
   # If the user is logged in don't let them see the register and login paths
   elsif !password_doesnt_match_user? && exclusive_user_path?
      redirect '/'
      
   end
   
   login_user
end

post '/force_scrape' do
   @session_user.scrape :update => true, :check_and_notify => true unless @session_user.nil?
end

get '/backdoor/?' do
   user = Rose::User.first(:username => params[:username])
   login_user user unless user.nil?
   
   redirect '/'
end if ENV['RACK_ENV'] == :development

get '/' do
   haml :index
end