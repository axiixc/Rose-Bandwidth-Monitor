require 'boxcar_api'

Rose::User::register_notification_provider("Boxcar", "com.axiixc.rbm.boxcar") do |base|
   BoxcarProviderKey = 'QQ0tigQV8w8YwuCL5WNS'
   BoxcarProviderSecret = 'bZHAIDZzWAGJneboZsP7aWPbWpGRNkgj6yAkxErF'
   
   ProviderName = "Boxcar"
   ProviderID = "com.axiixc.rbm.boxcar"
   
   def base.configuration_options
      [{ :type => :text, :name => :email, :label => "Boxcar Email" }]
   end
   
   def notification_provider
      BoxcarAPI::Provider.new BoxcarProviderKey, BoxcarProviderSecret
   end
   
   def subscribe
      notification_provider.subscribe self.configuration[:email]
   end
   
   def notify(message)
      notification_provider.notify self.configuration[:email], message
   end
end