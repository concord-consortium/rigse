module SendUpdateEvents
  
  def self.included(base)
    base.send(:extend, ClassMethods)
  end
  
  module ClassMethods
    
    def send_update_events_to(destination)
      class_eval do
        after_save UpdateEventSender.new(destination)
        after_destroy UpdateEventSender.new(destination)
      end
    end
    
    class UpdateEventSender
      
      def initialize(destination)
        @destination = destination
      end
      
      def after_save(record)
        _update_time(record)
      end
      
      def after_destroy(record)
        _update_time(record)
      end

      private
      
      def _update_time(record)
        obj = record.send @destination
        return unless obj
        dest_recs = obj.is_a?(Array) ? obj : [obj]
        dest_recs.each do |dest_rec|
          dest_rec.update_attribute(:updated_at, Time.now)
        end
      end
      
    end
    
  end
  
end

ActiveRecord::Base.send :include, SendUpdateEvents
