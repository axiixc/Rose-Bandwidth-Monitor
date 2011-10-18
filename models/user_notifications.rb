module Rose
   class User
      
      class << self
         @@notification_providers_array = []
         @@notification_providers_hash = {}
         
         def register_notification_provider(provider_name, provider_id)
            @@notification_providers_array << provider_id
            @@notification_providers_hash[provider_id] = {
               :name => provider_name,
               :class => Class.new do
                  include UserNotificationProviderDelegate
                  yield self
               end
            }
         end
         
         def notification_providers
            @@notification_providers_array
         end
         
         def notification_provider_class_with_id(provider_id)
            provider_info = @@notification_providers_hash[provider_id]
            provider_info[:class] unless provider_info.nil?
         end
         
         def notification_provider_name_with_id(provider_id)
            provider_info = @@notification_providers_hash[provider_id]
            provider_info[:name] unless provider_info.nil?
         end
      end
      
      def check_and_notify
         return if (not self.notification_enabled) or self.notification_providers.empty?
         
         bandwidth_entry = self.bandwidth_entries.all :order => [ :timestamp.desc ], :limit => 2
         return if bandwidth_entry.size < 1

         message = nil

         # If unrestricted, check for a warn notification
         if bandwidth_entry[0].bandwidth_class == 0.0 and 
               ((not bandwidth_entry[1].nil? and bandwidth_entry[1].policy_mbytes_received < self.notification_warn_level) and
               bandwidth_entry[0].policy_mbytes_received >= self.notification_warn_level)
            message = "Bandwidth usage at #{bandwidth_entry[0].policy_received_string}"

         # Send notifications when bandwidth class changes
         elsif bandwidth_entry[0].bandwidth_class != self.notification_last_bandwidth_class_value
            message = "Bandwidth class is now #{bandwidth_entry[0].bandwidth_class_string}, usage at #{bandwidth_entry[0].policy_received_string}"
            self.notification_last_bandwidth_class_value = bandwidth_entry[0].bandwidth_class
            self.save
         end

         return if message.nil?
         self.notification_providers.each { |provider| provider.notify message }
         puts "Notify #{self.username}: #{message}"
      end
   end
end