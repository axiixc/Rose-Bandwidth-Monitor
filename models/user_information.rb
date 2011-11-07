require 'rubygems'
require 'net/https'
require 'uri'
require 'ntlm/http'
require 'nokogiri'

module Rose
   class User
      SCHEDULE_URI = "https://prodweb.rose-hulman.edu/regweb-cgi/reg-sched.pl"
      
      @@term_id = nil
      TERM_EXPIRATION_WINDOW = 60 * 60 * 24 * 7 # 1 Week
      @@term_expiration = (Time.now - TERM_EXPIRATION_WINDOW - 1)
      
      def current_term_id
         if @@term_id.nil? || @@term_expiration < Time.now - TERM_EXPIRATION_WINDOW
            uri = URI.parse(SCHEDULE_URI)
            
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            
            request = Net::HTTP::Get.new(uri.request_uri)
            request.basic_auth(@username, @password)
            
            response = http.request(request)
            
            @@term_id = Nokogiri::HTML(response.body).xpath("//select[@name='termcode']/option[1]").to_ary[0].attributes["value"].value
            @@term_expiration = Time.now
         end
         
         @@term_id
      end
      
      def user_information_response
         if @user_information_response.nil?
            uri = URI.parse(SCHEDULE_URI)
         
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
            request = Net::HTTP::Post.new(uri.request_uri)
            request.basic_auth(@username, @password)
            request.form_data = { :termcode => self.current_term_id, :view => :tgrid, :id1 => @username, :bt1 => 'ID\Username' }
         
            @user_information_response = http.request(request)
         end
         
         @user_information_response
      end
      
      def display_name
         if @full_name.nil?
            name_components = Nokogiri::HTML(self.user_information_response.body).xpath("//table[1]//tr[2]/td[1]").to_ary[0].inner_text.split(' ')
            update :full_name => "#{name_components[1]} #{name_components[3]}"
         end
         
         @full_name
      end
   end
end