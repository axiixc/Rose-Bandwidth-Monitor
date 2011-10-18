module Rose
   class Device
      def display_name
         (not self.preferred_name.to_s.empty?) ? self.preferred_name : 
         (not self.host.to_s.empty?) ? self.host : self.network_address
      end
      
      def add_bandwidth_entry(scrape_dict, main_entry)
         bandwidth_entry = BandwidthDeviceEntry.create(
            :device => self,
            :main_entry => main_entry,
            :timestamp => Time.new,
            :policy_mbytes_received => scrape_dict[:policy_mbytes_received],
            :policy_mbytes_sent => scrape_dict[:policy_mbytes_sent],
            :actual_mbytes_received => scrape_dict[:actual_mbytes_received],
            :actual_mbytes_sent => scrape_dict[:actual_mbytes_sent]
         )
      end
   end
end