require 'date'
require 'yaml'

module Rose
   class User
      def report_cache_path(name)
         return "caches/reports/#{name}_#{self.username}.yaml"
      end
      
      def report_with_name(name, options = { :generate_if_missing => true, :generate_force => false})
         cache_name = report_cache_path name
         report_exists = File.exists? cache_name
         return ((!report_exists && options[:generate_if_missing]) || options[:generate_force]) ? _generate_report(name) : YAML.load_file(cache_name)
      end
      
      def _generate_report(name)
         report = Reports.send(name, self)
         
         p "GENERATE REPORT"
         File.open(report_cache_path(name), "w") { |cache_file| cache_file.write report.to_yaml }
         
         report
      end
   end
   
   module Reports
      Window_length = 36 * 60 * 60
      
      def Reports.iterate_over_user(user)
         row_length = 1
         device_mappings = {}
         devices = []
         
         user.devices.each do |device| 
            p device
            device_mappings[device.id] = (row_length += 1)
            devices << { :network_address => device.network_address, :host => device.host, :display_name => device.display_name, :index => row_length }
         end
         
         row_length += 1
         
         rows = []
         entries = user.bandwidth_entries.all(:timestamp.gte => Time.now - Window_length, :order => [ :timestamp.desc ])
         return { :devices => [], :rows => [], :metadata => {} } if (entries.size == 0)
         
         entries.each do |main_entry|
            yield(rows, row_length, device_mappings, main_entry)
         end
         
         newest_time = DateTime.datetime_to_time(entries[0].timestamp)
         oldest_time = DateTime.datetime_to_time(entries[entries.size - 1].timestamp)
         
         { 
            :devices => devices, 
            :rows => rows, 
            :metadata => { 
               :time_difference => (newest_time - oldest_time).to_i
            }
         }
      end
      
      def Reports.basic(user)
         return iterate_over_user(user) do |rows, row_length, device_mappings, main_entry|
            row = Array.new row_length, 0.0
            
            row[0] = main_entry.timestamp.strftime "%l:%M %P"
            row[1] = main_entry.policy_mbytes_received
            main_entry.device_entries.each do |device_entry|
               row[device_mappings[device_entry.device.id]] = device_entry.policy_mbytes_received
            end
            rows << row
         end
      end
      
      def Reports.real(user)
      end
      
      def Reports.stats(user)
      end
   end
end