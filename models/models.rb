require 'rubygems'
require 'data_mapper'
require 'dm-types'

module Rose
   def Rose.setup_datamapper(use_production = false, verbose = false)
      DataMapper::Logger.new($stdout, :debug) if verbose
      
      database_location = use_production ? 'stats.sqlite' : 'development-stats.sqlite'
      datamapper_location = 'sqlite3://' + File.join(Dir.pwd, database_location)
      DataMapper.setup(:default, datamapper_location)
      
      puts "Initializing Datamapper: #{database_location}" if verbose
      
      DataMapper.finalize
      DataMapper.auto_upgrade!
   end
   
   class User
      include DataMapper::Resource
   
      property :id, Serial
      property :username, String, :required => true
      property :password, String, :required => true
      property :pwhash, String
      property :protected_stats_token, String
      property :public_stats, Boolean, :default => false
      property :active, Boolean, :default => true
      property :last_status_code, String
      property :notification_warn_level, Float, :default => 3500.0
      property :notification_last_bandwidth_class_value, Float, :default => -1.0
      property :notification_enabled, Boolean, :default => false
      property :notification_boxcar_email, String
   
      has n, :bandwidth_entries, :model => 'BandwidthMainEntry'
      has n, :devices, :order => [ :network_address.desc ]
      has n, :pending_notifications, :model => 'Notification'
      has n, :notification_providers, :model => 'UserNotificationProvider'
   end
   
   class UserNotificationProvider
      include DataMapper::Resource
      
      property :id, Serial
      property :provider_id, String
      property :enabled, Boolean, :default => true
      property :user_configuration, Yaml
      property :provider_configuration, Yaml
      
      belongs_to :user
   end
   
   class Device
      include DataMapper::Resource

      belongs_to :user

      property :id, Serial
      property :network_address, String
      property :host, String
      property :preferred_name, String

      has n, :bandwidth_entries, :model => 'BandwidthDeviceEntry'
   end
   
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
   end
   
   class BandwidthMainEntry
      include BandwidthEntry

      belongs_to :user

      property :bandwidth_class, Float
      has n, :device_entries, :model => 'BandwidthDeviceEntry', :child_key => [ :main_entry_id ]
   end
   
   class BandwidthDeviceEntry
      include BandwidthEntry
   
      belongs_to :device
      belongs_to :main_entry, :model => 'BandwidthMainEntry'
   end
   
   class Notification
      include DataMapper::Resource
      
      belongs_to :user
      
      property :id, Serial
      property :message, String
      property :type, Enum[ :success, :notice, :warning, :error ]
   end
end