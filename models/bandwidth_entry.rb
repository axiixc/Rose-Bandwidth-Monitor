require './value_formatting.rb'

module Rose
   module BandwidthEntry
      def policy_received_string
         Rose.string_from_mbytes self.policy_mbytes_received
      end
   
      def policy_sent_string
         Rose.string_from_mbytes self.policy_mbytes_sent
      end
   
      def actual_received_string
         Rose.string_from_mbytes self.actual_mbytes_received
      end
   
      def actual_sent_string
         Rose.string_from_mbytes self.actual_mbytes_sent
      end
      
      TimestampFormat = "%l:%M %P"
      
      def pretty_timestamp
         self.timestamp.strftime TimestampFormat
      end
      
      def data_age
         Rose.humanize_pretty DateTime.now - self.timestamp
      end
      
      def self.api_representation(user, window_length = 60 * 60 * 36)
         user.bandwidth_entries.all({
            :timestamp.gte => Time.now - window_length,
            :order => [ :timestamp.desc ]
         }).map do |main_entry|
            {
               id: main_entry.id,
               username: user.username,
               bandwidth_class: main_entry.bandwidth_class,
               
               policy_mbytes_received: main_entry.policy_mbytes_received,
               policy_mbytes_sent: main_entry.policy_mbytes_sent,
               actual_mbytes_received: main_entry.actual_mbytes_received,
               actual_mbytes_sent: main_entry.actual_mbytes_sent,
               timestamp: main_entry.timestamp,
               
               device_entries: main_entry.device_entries.map do |device_entry|
                  {
                     id: device_entry.id,
                     parent_id: main_entry.id,
                     device_id: device_entry.device.network_address,
                     
                     policy_mbytes_received: device_entry.policy_mbytes_received,
                     policy_mbytes_sent: device_entry.policy_mbytes_sent,
                     actual_mbytes_received: device_entry.actual_mbytes_received,
                     actual_mbytes_sent: device_entry.actual_mbytes_sent,
                     timestamp: device_entry.timestamp,
                  }
               end
            }
         end
      end
   end

   class BandwidthMainEntry
      def bandwidth_class_string
         return "unrestricted" if self.bandwidth_class == 0.0
         Rose.string_from_kbytes self.bandwidth_class, '/s'
      end
   end

   class BandwidthDeviceEntry
   end
end