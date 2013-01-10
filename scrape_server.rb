require './date_time_util'

['models', 'notification_providers'].each do |dir_name|
   Dir["#{dir_name}/*"].each { |file| require "./#{file}" }
end

Rose.setup_datamapper ARGV.include? '--production'
Rose.reset_caches

Sleep_interval = 5

loop do
   Rose::ScrapeEvent.scrape_all
   
   puts "Scrape complete! Sleeping for #{Sleep_interval} minutes..."
   sleep 60 * Sleep_interval
end
