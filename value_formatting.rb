module Rose
   def Rose.string_from_kbytes kbytes, suffix = ''
      byte_size = 1024.0
      string_sizes = ['KB', 'MB', 'GB', 'TB', 'PB']
      
      string_sizes.each_index do |idx|
         adjusted_size = kbytes / (byte_size ** idx.to_f)
         if adjusted_size < byte_size
            return '%.2f %s%s' % [adjusted_size, string_sizes[idx], suffix]
         end
      end
      
      return '%.2f %s%s' % [kbytes, string_sizes[idx], suffix]
   end
   
   def Rose.string_from_mbytes mbytes, suffix = ''
      Rose.string_from_kbytes mbytes * 1024, suffix
   end
   
   def Rose.humanize_pretty secs
       secs = secs.to_i
       case secs
          when 0..5 then return 'just now'
          when 6..59 then return secs.to_s+' seconds ago' 
          when 60..119 then return 'a minute ago' #120 = 2 minutes
          when 120..3540 then return (secs/60).to_i.to_s+' minutes ago'
          when 3541..7100 then return 'an hour ago' # 3600 = 1 hour
          when 7101..82800 then return ((secs+99)/3600).to_i.to_s+' hours ago' 
          when 82801..172000 then return 'a day ago' # 86400 = 1 day
          when 172001..518400 then return ((secs+800)/(60*60*24)).to_i.to_s+' days ago'
          when 518400..1036800 then return 'a week ago'
          else return ((secs+180000)/(60*60*24*7)).to_i.to_s+' weeks ago'
       end
   end
end