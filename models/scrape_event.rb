module Rose
   class ScrapeEvent
      def self.scrape_all
         scrape_event = self.new
         User.all(:active => true).each do |user|
            begin
               user.scrape scrape_event
            rescue Exception => e
               puts e.backtrace
            end
         end
         scrape_event.save
      end
   end
end
