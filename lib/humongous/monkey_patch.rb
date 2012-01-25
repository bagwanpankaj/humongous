module Humongous
  
  module MonkeyPatch
    
    module MonkeyObject
      def blank?
        self.respond_to?(:empty?) ? empty? : nil?
      end
      
      def self.activate!
        Object.send(:include, self)
      end
    end
    
    #monkey patch for string
    module MonkeyString
      def self.activate!
      end
    end
    
    def self.activate!
      [MonkeyObject, MonkeyString].collect(&:activate!)
    end
  end
  
end