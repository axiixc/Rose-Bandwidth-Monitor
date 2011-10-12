require 'boxcar_api'

module Rose
   class User
      Boxcar_provider_key = 'QQ0tigQV8w8YwuCL5WNS'
      Boxcar_provider_secret = 'bZHAIDZzWAGJneboZsP7aWPbWpGRNkgj6yAkxErF'
      
      @provider = nil
      
      def notification_provider
         @provider = BoxcarAPI::Provider.new(Boxcar_provider_key, Boxcar_provider_secret) if @provider.nil?
         @provider
      end
      
      def subscribe!
         self.notification_provider.subscribe self.notification_boxcar_email
      end
      
      def check_and_notify
         return unless self.notification_enabled
         return if self.notification_boxcar_email.nil?
         bandwidth_entry = self.bandwidth_entries.all :order => [ :timestamp.desc ], :limit => 2
         return unless bandwidth_entry.size >= 1
         
         message = nil
         
         # If unrestricted, check for a warn notification
         if bandwidth_entry[0].bandwidth_class == 0.0 and 
               ((not bandwidth_entry[1].nil? and bandwidth_entry[1].policy_mbytes_received < self.notification_warn_level) and
               bandwidth_entry[0].policy_mbytes_received >= self.notification_warn_level)
            message = "Bandwidth usage at #{bandwidth_entry[0].policy_received_string}"
         
         # Send notifications when bandwidth class changes
         elsif bandwidth_entry[0].bandwidth_class != self.notification_last_bandwidth_class_value
            message = "Bandwidth class is now #{bandwidth_entry[0].bandwidth_class_string}"
            self.notification_last_bandwidth_class_value = bandwidth_entry[0].bandwidth_class
            self.save
         end
         
         return if message.nil?
         self.notification_provider.notify self.notification_boxcar_email, message
         puts "Notify #{self.username}: #{message}"
      end
   end
end