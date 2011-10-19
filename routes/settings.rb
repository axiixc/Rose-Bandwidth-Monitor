post '/settings/notifications/?' do
   if params[:disable_notifications]
      @session_user.notification_providers.each { |provider| provider.update :enabled => false }
   else
      warn_level = params[:warn_level].to_f
      @session_user.update(:notification_warn_level => warn_level) unless warn_level <= 0.0
      
      params[:provider_id].each do |index, provider_id|
         provider = @session_user.notification_providers.first :provider_id => provider_id
         provider_enabled = !params[:enabled][index].to_s.empty?
         
         next if provider.nil? && !provider_enabled
         
         provider = Rose::UserNotificationProvider.create :user => @session_user, :provider_id => provider_id if provider.nil?
         provider.enabled = provider_enabled
         
         provider.user_configuration = {}
         provider.delegate.configuration_options.each { |opt| provider.user_configuration[opt[:name]] = params[opt[:name]].nil? ? nil : params[opt[:name]][index] }
         provider.save
      end
   end
   
   redirect '/'
end

post '/settings/notifications--old/?' do
   if not params[:disable_notifications].nil?
      @session_user.notification_enabled = false
   else
      # If the email has changed, resubmit for subscription
      if @session_user.notification_enabled && params[:email].nil?
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

post '/settings/devices/?' do
   params[:network_address].each_with_index do |network_address, index|
      return if (device = @session_user.devices.first :network_address => network_address).nil?
      name = params[:preferred_name][index]
      device.preferred_name = name.to_s.empty? ? nil : name
      device.save
   end
   
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