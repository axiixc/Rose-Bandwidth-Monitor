require 'rubygems'
require 'net/https'
require 'uri'
require 'ntlm/http'
require 'nokogiri'

module Rose
   class User
      # TODO: Make this configurable?
      SCRAPE_URL = "https://netreg.rose-hulman.edu/tools/networkUsage.pl"
      DOMAIN = "rose-hulman.edu"
   
      # TODO: Make this configurable? Or better yet "more easily patched"
      FMT_MAIN = "//div[@class='mainContainer']/table[@class='ms-rteTable-1'][1]/tr[@class!='ms-rteTableHeaderRow-1']/td"
      FMT_DEVICES = "//div[@class='mainContainer']/table[@class='ms-rteTable-1'][2]/tr[@class!='ms-rteTableHeaderRow-1']/td"
   
      @scrape_dict = nil
   
      def can_scrape?
         self.scrape_bandwidth if self.last_status_code.nil?
         self.last_status_code == "200"
      end
      
      def scrape(options = { :update => false, :check_and_notify => false })
         self.add_bandwidth_entry if options[:update]
         self.check_and_notify if options[:check_and_notify]
      end
   
      def scrape_dict
         self.create_scrape_dict if @scrape_dict.nil?
         @scrape_dict
      end
   
      def create_scrape_dict
         response = self.scrape_bandwidth
         if response.code != '200'
            puts "ERR: #{self.username} got #{response.code} on scrape"
            return
         end
         
         response = response.body
         
         devices = []
         device_nodes = Nokogiri::HTML(response).xpath(FMT_DEVICES).to_ary
         num_devices = (device_nodes.size / 7).floor
         num_devices.times do |base_idx|
            base_idx *= 7
            devices << {
               :network_address => self.clean_element_string(device_nodes[base_idx + 0]),
               :host => self.clean_element_string(device_nodes[base_idx + 1]),
               :policy_mbytes_received => self.clean_element_byte_value(device_nodes[base_idx + 3]),
               :policy_mbytes_sent => self.clean_element_byte_value(device_nodes[base_idx + 4]),
               :actual_mbytes_received => self.clean_element_byte_value(device_nodes[base_idx + 5]),
               :actual_mbytes_sent => self.clean_element_byte_value(device_nodes[base_idx + 6])
            }
         end
         
         main_nodes = Nokogiri::HTML(response).xpath(FMT_MAIN).to_ary
         
         @scrape_dict = { 
            :main => {
               :bandwidth_class => self.clean_element_bandwidth_class(main_nodes[0]),
               :policy_mbytes_received => self.clean_element_byte_value(main_nodes[1]),
               :policy_mbytes_sent => self.clean_element_byte_value(main_nodes[2]),
               :actual_mbytes_received => self.clean_element_byte_value(main_nodes[3]),
               :actual_mbytes_sent => self.clean_element_byte_value(main_nodes[4])
            }, 
            :devices => devices
         }
      end
   
      def scrape_bandwidth
         uri = URI.parse(SCRAPE_URL)
      
         http = Net::HTTP.new(uri.host, uri.port)
         http.use_ssl = true
         http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
         request = Net::HTTP::Get.new(uri.request_uri)
         request.ntlm_auth(@username, DOMAIN, @password)
         
         # TODO: Handle errors for no-connection, invalid-connection, invalid-auth
         response = http.request(request)
         self.last_status_code = response.code
      
         response
      end
   
      def clean_element_bandwidth_class(element)
         text = element.inner_text
         text.sub! /[A-Za-z ]/, ""
         text.to_f
      end
   
      def clean_element_byte_value(element)
         text = element.inner_text
         text.sub! " MB", ""
         text.sub! ",", ""
         text.to_f
      end
   
      def clean_element_string(element)
         element.inner_text
      end
   end
end