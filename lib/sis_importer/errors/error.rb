module SisImporter
  module Errors  
    class Error <  StandardError
      attr_accessor :original
      def initialize(message,original=$!)
        super(message)
        @original = original
      end
    end
    
    class FatalError < Error
    end

  end
end
