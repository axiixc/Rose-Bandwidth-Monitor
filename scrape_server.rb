Dir['models/*'].each { |model| require './' + model }
Dir['notification_providers/*'].each { |provider| require './' + provider }

Rose.setup_datamapper ARGV.include? '--production'
Sleep_interval = 30

loop do
   Rose::User.all(:active => true).each do |user|
      user.scrape :update => true, :check_and_notify => true
   end
   
   puts "Scrape complete! Sleeping for #{Sleep_interval} minutes..."
   sleep(60 * Sleep_interval)
end
