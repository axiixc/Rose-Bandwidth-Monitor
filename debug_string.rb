class Object
   def debug_string(indent_string = "")
      to_s
   end
end

class Hash
   def debug_string(indent_string = "")
      retVal = "{\n"
      self.each do |key, value|
         value = value.debug_string(indent_string + "\t")
         retVal += "#{indent_string}\t#{key} : #{value}\n"
      end
      retVal + "#{indent_string}}"
   end
end

class Array
   def debug_string(indent_string = "")
      retVal = "[\n"
      self.each do |value|
         value = value.debug_string(indent_string + "\t")
         retVal += "#{indent_string}\t#{value}\n"
      end
      retVal + "#{indent_string}]"
   end
end