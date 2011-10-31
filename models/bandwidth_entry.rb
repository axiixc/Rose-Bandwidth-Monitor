require './value_formatting.rb'

module Rose
   module BandwidthEntry
      def self.included(base)
         base.class_eval do
            include DataMapper::Resource

            property :id, DataMapper::Property::Serial
            property :policy_mbytes_received, DataMapper::Property::Float
            property :policy_mbytes_sent, DataMapper::Property::Float
            property :actual_mbytes_received, DataMapper::Property::Float
            property :actual_mbytes_sent, DataMapper::Property::Float
            property :timestamp, DataMapper::Property::DateTime
         end
      end
   
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
      
      def data_age
         DateTime.humanize_pretty Time.new - DateTime.datetime_to_time(self.timestamp)
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