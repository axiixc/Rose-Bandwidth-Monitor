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
   
      def add_bandwidth_entry(scrape_dict = nil)
         scrape_dict ||= self.scrape_dict
         return if scrape_dict.nil?
         
         # Create and add the main entry
         main_entry = BandwidthMainEntry.create(
            :user => self,
            :timestamp => Time.new,
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
   end
end