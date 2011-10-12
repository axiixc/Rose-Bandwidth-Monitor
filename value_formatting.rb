module Rose
   def Rose.string_from_kbytes(kbytes, suffix = '')
      byte_size = 1024
      size_strings = ['KB', 'MB', 'GB', 'TB', 'PB']
      size_strings.each_index do |idx|
         byte_size_mult = byte_size ** idx
         return '%.2f %s%s' % [kbytes / byte_size_mult, size_strings[idx], suffix] if kbytes / byte_size_mult < byte_size
      end
      
      # TODO: Better fallback?
      return '%.2f KB%s' % [kbytes, suffix]
   end
   
   def Rose.string_from_mbytes(mbytes, suffix = '')
      Rose.string_from_kbytes mbytes * 1024, suffix
   end
end