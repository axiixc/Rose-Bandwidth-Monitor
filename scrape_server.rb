Dir['models/*'].each { |model| require './' + model }
Dir['notification_providers/*'].each { |provider| require './' + provider }
require './date_time_util'

Rose.setup_datamapper ARGV.include? '--production'
Sleep_interval = 15

loop do
   Rose::ScrapeEvent.scrape_all
   
   puts "Scrape complete! Sleeping for #{Sleep_interval} minutes..."
   sleep(60 * Sleep_interval)
end
