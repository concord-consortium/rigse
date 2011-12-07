module SisImporter
  module Errors  
    class Error <  Exception
      attr_accessor :original
      def initialize(message,original=$!)
        super(message)
        @original = original
      end
    end


    class FatalError < Error
    end

    class MissingDistrictFolderError < Error
      attr_accessor :folder
      def initialize(district_folder,original=$!)
        message = "Missing District Folder: #{district_folder}"
        super(message,original)
        self.folder = district_folder
      end
    end

    class TransportError < Error
    end
    
    class ConnectionError < FatalError
    end

  end
end
