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
      
      def notify(message)
         delegate.notify message
      end
   end
   
   module UserNotificationProviderDelegate
      def self.included(base)
         base.class_eval do
            attr_reader :user
            attr_reader :provider
            
            def base.configuration_options
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
      
      def subscribe
      end
      
      def unsubscribe
      end
      
      def notify(message)
      end
   end
end