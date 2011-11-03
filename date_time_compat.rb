# Compatibility between 1.8 and 1.9 for time conversion
# and other helper methods

module Rose
   module DateTimeUtil
      def self.datetime_to_time(dest)
         usec = (dest.sec_fraction * 60 * 60 * 24 * (10**6)).to_i
         Time.send(:local, dest.year, dest.month, dest.day, dest.hour, dest.min, dest.sec, usec)
      end
      
      def self.humanize(secs)
         [[60, :second], [60, :minute], [24, :hour], [1000, :day]].map { |count, name|
            if secs > 0
               secs, n = secs.divmod(count)
               "#{n.to_i} #{name}#{n.to_i == 1 ? "" : :s}"
            end
         }.compact.reverse.join(' ')
      end
      
      def self.humanize_rounded(secs)
         [[86400, :day], [3600, :hour], [60, :minute], [1, :second]].each do |group|
            n = secs / group[0]
            return "#{n.to_i} #{group[1]}#{n.to_i == 1 ? "" : :s}" unless n < 1
         end
      end
      
      def self.humanize_pretty(secs)
         secs = secs.to_i
         case secs
           when 0 then return 'just now'
           when 1 then return 'a second ago'
           when 2..59 then return secs.to_s+' seconds ago' 
           when 60..119 then return 'a minute ago' #120 = 2 minutes
           when 120..3540 then return (secs/60).to_i.to_s+' minutes ago'
           when 3541..7100 then return 'an hour ago' # 3600 = 1 hour
           when 7101..82800 then return ((secs+99)/3600).to_i.to_s+' hours ago' 
           when 82801..172000 then return 'a day ago' # 86400 = 1 day
           when 172001..518400 then return ((secs+800)/(60*60*24)).to_i.to_s+' days ago'
           when 518400..1036800 then return 'a week ago'
         end
         
         return ((secs+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
      end
   end
end