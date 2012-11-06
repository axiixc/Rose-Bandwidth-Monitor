module Rose
   class Device
      def self.api_representation(user)
         raise nil if user.nil?
         
         user.devices.map do |device|
            {
               user: user.username,
               network_address: device.network_address,
               host: device.host,
               preferred_name: device.preferred_name
            }
         end
      end
      
      def display_name
         (!self.preferred_name.to_s.empty?) ? self.preferred_name : 
         (!self.host.to_s.empty?) ? self.host : self.network_address
      end
      
      def add_bandwidth_entry(scrape_dict, main_entry)
         bandwidth_entry = BandwidthDeviceEntry.create(
            :device => self,
            :main_entry => main_entry,
            :timestamp => Time.now,
            :policy_mbytes_received => scrape_dict[:policy_mbytes_received],
            :policy_mbytes_sent => scrape_dict[:policy_mbytes_sent],
            :actual_mbytes_received => scrape_dict[:actual_mbytes_received],
            :actual_mbytes_sent => scrape_dict[:actual_mbytes_sent]
         )
      end
   end
end