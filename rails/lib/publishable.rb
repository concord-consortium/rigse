
module Publishable
  ##
  ## Called when a class extends this module:
  ##
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do

      @@protected_publication_states=[:published]
      @@publication_states = [:draft,:published,:private]

      # this needs to come after the class variable definition...
      cattr_accessor :publication_states

      def publish!
        self.publication_status = "published"
      end

      def un_publish!
        self.publication_status = "draft"
      end

      scope :published, -> {
        where(:publication_status => "published")
      }

      def available_states(who_wants_to_know)
        if(who_wants_to_know.has_role?('manager','admin'))
          return @@publication_states
        end
        publication_states = @@publication_states - @@protected_publication_states
        if self.publication_status
          publication_states << self.publication_status.to_sym
        end
        return publication_states.uniq
      end

      def public?
        return publication_status == 'published'
      end

      def published?
        public?
      end
    end
  end
end
