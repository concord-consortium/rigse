module SisImporter
  module Errors  

    module Collector
      @collections = {}

      def self.collection_for(thing)
        return (@collections[thing]  ||= {})
      end

      def errors(tag=:all)
        return (Collector.collection_for(self)[tag] ||= [])
      end

      def error(exc, tags=[])
        self.logger.error(exc.message)
        tags << :all
        tags.each { |tag| errors(tag) << exc }
        raise exc if exc.kind_of? FatalError
      end
    end

  end
end
