module Rose
   class UserNotificationProvider
      def provider_delegate
         if @provider_delegate.nil?
            provider_class = User::notification_provider_class_with_id(self.provider_id)
            @provider_delegate = provider_class.new(self.user, self) unless provider_class.nil?
         end
         
         @provider_delegate
      end
      
      def subscribe
         provider_delegate.subscribe
      end
      
      def unsubscribe
         provider_delegate.unsubscribe
      end
      
      def notify(message)
         provider_delegate.notify message
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
      
      def subscribe
      end
      
      def unsubscribe
      end
      
      def notify
      end
   end
end