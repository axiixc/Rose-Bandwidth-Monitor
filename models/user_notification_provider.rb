module Rose
   class UserNotificationProvider
      def delegate
         if @delegate.nil?
            provider_class = User::notification_provider_class_with_id(self.provider_id)
            @delegate = provider_class.new(self.user, self) unless provider_class.nil?
         end
         
         @delegate
      end
      
      def enabled=(enabled)
         call_delegate = enabled ^ self.enabled
         super enabled
         delegate.send(enabled ? :subscribe : :unsubscribe) if call_delegate
      end
      
      def notify(notification)
         delegate.notify notification
      end
   end
   
   module UserNotificationProviderDelegate
      def self.included(base)
         base.class_eval do
            attr_reader :user
            attr_reader :provider
            
            
            def base.configuration_options
               # Valid options and return format:
               # [
               #    { :type => :text, :name => :text, :label => "Text" },
               #    { :type => :password, :name => :password, :label => "Password" },
               #    { :type => :checkbox, :name => :checkbox, :label => "Checkbox" }
               # ]
            end
         end
      end
      
      def initialize(user, provider)
         @user = user
         @provider = provider
      end
      
      def configuration_options
         self.class.configuration_options
      end
      
      # Called every time your service is switched from inactive to active
      def subscribe
      end
      
      # Called every time your service is switched form active to inactive
      def unsubscribe
      end
      
      def notify(notification)
         # notification[:type] -> :warn_level, the user's policy usage has suprassed their warn level
         #                     -> :bandwidth_class, the user's bandwidth class has changed
         # notification[:entry] -> The entry which triggered this notification
      end
   end
end