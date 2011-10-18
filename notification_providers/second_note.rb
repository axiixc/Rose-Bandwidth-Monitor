# Rose::User::register_notification_provider("Second Note", "com.axiixc.rbm.sn") do |base|
#    def base.configuration_options
#       [
#          { :type => :text, :name => :text, :label => "Text" },
#          { :type => :password, :name => :password, :label => "Password" },
#          { :type => :checkbox, :name => :checkbox, :label => "Checkbox" }
#       ]
#    end
#    
#    def notify(message)
#       puts "Hey, #{self.user.username}, #{message}"
#    end
# end