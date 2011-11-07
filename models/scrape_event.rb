module Rose
   class ScrapeEvent
      def self.scrape_all
         scrape_event = self.new
         User.all(:active => true).each { |user| user.scrape scrape_event }
         scrape_event.save
      end
   end
end
