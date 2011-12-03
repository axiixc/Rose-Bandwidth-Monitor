module Rose
   class User
      class << self
         @@notification_providers_array = []
         @@notification_providers_hash = {}
         
         def register_notification_provider(provider_name, provider_id, provider_class)
            raise "Duplicate notification provider ID registered (#{provider_id})" if @@notification_providers_array.include? provider_id
            
            @@notification_providers_array << provider_id
            @@notification_providers_hash[provider_id] = {
               :name => provider_name,
               :class => provider_class
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
         # No point in checking if there are no providers
         return if self.notification_providers.all(:enabled => true).empty?
         
         current_entry, last_entry = self.bandwidth_entries.all :order => [ :timestamp.desc ], :limit => 2
         return if current_entry.nil? # Or if there is no data
         
         # If unrestricted, check for a warn notification
         if current_entry.bandwidth_class == 0.0 &&
               ((!last_entry.nil? && last_entry.policy_mbytes_received < self.notification_warn_level) &&
               current_entry.policy_mbytes_received >= self.notification_warn_level)
            notification = { :type => :warn_level, :entry => current_entry }

         # Send notifications when bandwidth class changes
         elsif current_entry.bandwidth_class != self.notification_last_bandwidth_class_value
            notification = { :type => :bandwidth_class, :entry => current_entry }
            self.update :notification_last_bandwidth_class_value => current_entry.bandwidth_class
         end
         
         self.notification_providers.all(:enabled => true).each { |provider| provider.notify notification } unless notification.nil?
      end
   end
end