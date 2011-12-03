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
         DateTimeUtil.humanize_pretty Time.now - DateTimeUtil.datetime_to_time(self.timestamp)
      end
   end

   class BandwidthMainEntry
      def bandwidth_class_string
         return "unrestricted" if self.bandwidth_class == 0.0
         Rose.string_from_kbytes self.bandwidth_class, '/s'
      end
   end

   # class BandwidthDeviceEntry
   # end
end