require 'digest/sha1'

module Rose
   class User
      def self.hash_password(password)
         Digest::MD5.hexdigest password
      end
      
      def password=(new_pw)
         super new_pw
         self.pwhash = self.class.hash_password new_pw
         @can_scrape = nil
      end

      def reset_protected_stats_token
         self.protected_stats_token = Digest::SHA1.hexdigest self.pwhash + Time.now.to_s
      end
      
      def current_usage
         self.bandwidth_entries.first :order => [ :timestamp.desc ]
      end
      
      def each_pending_notification(options = {:destroy => false})
         self.pending_notifications.each do |notification|
            yield notification
            notification.destroy if options[:destroy]
         end
      end
      
      def add_notification(message, type = :notice)
         Notification.create(
            :user => self,
            :message => message,
            :type => type
         )
      end
   
      def add_bandwidth_entry(scrape_event = nil)
         return if scrape_dict.nil?
         
         # Create and add the main entry
         main_entry = BandwidthMainEntry.create(
            :user => self,
            :scrape_event => scrape_event,
            :timestamp => Time.now,
            :policy_mbytes_received => scrape_dict[:main][:policy_mbytes_received],
            :policy_mbytes_sent => scrape_dict[:main][:policy_mbytes_sent],
            :actual_mbytes_received => scrape_dict[:main][:actual_mbytes_received],
            :actual_mbytes_sent => scrape_dict[:main][:actual_mbytes_sent],
            :bandwidth_class => scrape_dict[:main][:bandwidth_class]
         )
      
         # Create and save any device entries
         scrape_dict[:devices].each do |device_dict|
            Device.first_or_create(
               :user => self, 
               :network_address => device_dict[:network_address],
               :host => device_dict[:host]
            ).add_bandwidth_entry(device_dict, main_entry) 
         end
      end
      
      def api_representation(level = :minimal)
         if level == :full
            {
               id: self.id,
               username: self.username,
               display_name: self.display_name,
               public_stats: self.public_stats,
               active: self.active,
               notification_warn_level: self.notification_warn_level
            }
         else
            {
               id: self.id,
               username: self.username,
               display_name: self.display_name,
               public_stats: self.public_stats
            }
         end
      end
   end
end
