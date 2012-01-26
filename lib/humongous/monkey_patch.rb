module Humongous
  
  module MonkeyPatch
    
    module MonkeyObject
      # checks object and return true or false
      def blank?
        self.respond_to?(:empty?) ? empty? : nil?
      end
      
      #activates monkey patch on object
      def self.activate!
        Object.send(:include, self)
      end
    end
    
    #monkey patch for string
    module MonkeyString
      #activates module patch on string
      def self.activate!
      end
    end
    # top level activate method
    def self.activate!
      [MonkeyObject, MonkeyString].collect(&:activate!)
    end
  end
  
end