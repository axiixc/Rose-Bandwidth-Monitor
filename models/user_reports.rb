require 'date'
require 'yaml'

module Rose
   class User
      def self.report_with_name(name, force_generate = false)
         Reports.fetch_report Reports::Query.new(name, :all, ScrapeEvent.all, force_generate)
      end
      
      def report_with_name(name, force_generate = false)
         Reports.fetch_report Reports::Query.new(name, :single, self, force_generate)
      end
   end
   
   module Reports
      
      class Query
         attr_reader :name, :type, :attachment, :force_generate
         
         def initialize(name, type, attachment, force_generate = false)
            @name = name
            @type = type
            @attachment = attachment
            @force_generate = force_generate
         end
      end
      
      CachePath = "caches/reports"
      
      def self.make_cache_path(query)
         filename = (query.type == :all) ? "all_#{query.name}.yaml" : "single_#{query.attachment.username}_#{query.name}.yaml"
         return File.join CachePath, filename
      end
      
      def self.fetch_report(query)
         cache_path = make_cache_path query
         return (!File.exists?(cache_path) || query.force_generate) ? generate_report(query) : YAML.load_file(cache_path)
      end
      
      def self.generate_report(query)
         report = (query.type == :all) ? AllUsers.send(query.name, query.attachment) : SingleUser.send(query.name, query.attachment)
         File.open(make_cache_path(query), 'w') { |f| f.write(report.to_yaml) }
         report
      end
      
      WindowLength = 36 * 60 * 60
      
      module SingleUser
         def self.iterate_over_user(user)
            row_length = 1
            device_mappings = {}
            devices = []
         
            user.devices.each do |device| 
               device_mappings[device.id] = (row_length += 1)
               devices << {
                  :network_address => device.network_address,
                  :host => device.host,
                  :display_name => device.display_name,
                  :index => row_length
               }
            end
         
            row_length += 1
         
            rows = []
            entries = user.bandwidth_entries.all(:timestamp.gte => Time.now - WindowLength, :order => [ :timestamp.desc ])
            return { :devices => [], :rows => [], :metadata => {} } if (entries.size == 0)
         
            entries.each do |main_entry|
               yield(rows, row_length, device_mappings, main_entry)
            end
         
            newest_time = entries[0].timestamp
            oldest_time = entries.last.timestamp
         
            { 
               :devices => devices, 
               :rows => rows, 
               :metadata => { 
                  :time_difference => (newest_time - oldest_time).to_i
               }
            }
         end
      
         def self.basic(user)
            return iterate_over_user(user) do |rows, row_length, device_mappings, main_entry|
               row = Array.new row_length, 0.0
            
               row[0] = main_entry.pretty_timestamp
               row[1] = main_entry.policy_mbytes_received
               main_entry.device_entries.each { |device_entry| row[device_mappings[device_entry.device.id]] = device_entry.policy_mbytes_received }
            
               rows << row
            end
         end
      end #-- End SingleUser Module
      
      module AllUsers
         def self.iterate_over_events(events)
         end
         
         def self.basic(events)
         end
      end #-- End AllUsers Module
   end
end