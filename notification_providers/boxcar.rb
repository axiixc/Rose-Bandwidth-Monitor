require 'boxcar_api'

module BoxcarAPI
   class Provider
      def self.post(arg0, params)
         proc = Proc.new { |k, v| v.kind_of?(Hash) ? (v.delete_if(&proc); nil) : v.nil? }
         params.delete_if(&proc)
         super arg0, params
      end
   end
end

class BoxcarAPINotificationProvider
   include Rose::UserNotificationProviderDelegate
   
   BoxcarProviderKey = 'QQ0tigQV8w8YwuCL5WNS'
   BoxcarProviderSecret = 'bZHAIDZzWAGJneboZsP7aWPbWpGRNkgj6yAkxErF'
   
   ProviderName = "Boxcar"
   ProviderID = "com.axiixc.rbm.boxcar"
   
   def self.configuration_options
      [{ :type => :text, :name => :email, :label => "Boxcar Email" }]
   end
   
   def boxcar_provider
      BoxcarAPI::Provider.new BoxcarProviderKey, BoxcarProviderSecret
   end
   
   def subscribe
      boxcar_provider.subscribe self.provider.user_configuration[:email]
      boxcar_provider.notify self.provider.user_configuration[:email], "Hey, you're signed up bandwidth notifications!"
   end
   
   def notify(notification)
      case notification[:type]
      when :bandwidth_class
         message = "Bandwidth class now #{notification[:entry].bandwidth_class_string}, usage at #{notification[:entry].policy_received_string}"
      else
         message = "Usage at #{notification[:entry].policy_received_string}"
      end
      
      boxcar_provider.notify self.provider.user_configuration[:email], message
   end
end

Rose::User::register_notification_provider("Boxcar", "com.axiixc.rbm.boxcar", BoxcarAPINotificationProvider)