post '/settings/notifications/?' do
   if not params[:disable_notifications].nil?
      @session_user.notification_enabled = false
   else
      # If the email has changed, resubmit for subscription
      if @session_user.notification_enabled and params[:email].nil?
         @session_user.add_notification "Notifications disabled. Please enter a boxcar email address.", :warning
      elsif @session_user.notification_boxcar_email.nil? or not (params[:email].nil? or @session_user.notification_boxcar_email == params[:email])
         fork { @session_user.subscribe! }
      end
   
      # Write the rest of the configuration
      @session_user.notification_boxcar_email = params[:email]
      @session_user.notification_enabled = !params[:email].empty?
      
      warn_level = params[:warn_level].to_f
      @session_user.notification_warn_level = warn_level unless warn_level <= 0.0
   end
   
   @session_user.save
   
   redirect '/'
end

post '/settings/password/?' do
   # Only update password if current is passed
   if not params[:current_password].empty?
      pwhash = Rose::User.hash_password params[:current_password]
      if pwhash != @session_user.pwhash
         @session_user.add_notification "Current Password Invalid", :error
      elsif params[:new_password] != params[:new_password_confirm]
         @session_user.add_notification "New Passwords Do Not Match", :error
      else
         @session_user.password = params[:new_password]
         login_user @session_user # Need to update pwhash in user's cookies
         @session_user.add_notification "Password Updated", :success 
      end
   end
end

post '/settings/profile/?' do
   if params[:reset_protected_stats_token]
      @session_user.reset_protected_stats_token
   end
   
   @session_user.public_stats = (params[:public_stats] == 'public_stats')
   @session_user.save
   
   redirect '/'
end