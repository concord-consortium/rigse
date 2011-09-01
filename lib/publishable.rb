require 'aasm'
#
#  Methods for containers that can be made public through some workflow
#  (challenge will be defining this in a project agnostic way...)
#
module Publishable
  ##
  ## Called when a class extends this module:
  ##
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval do
      # use rubyist-aasm gem (acts_as_state_machine)
      # for publication status:
      # see: http://www.practicalecommerce.com/blogs/post/440-Acts-As-State-Machine-Is-Now-A-Gem
      # and http://www.ruby-forum.com/topic/179721
      # for a discussion on how the new aasm gem differs from the old plugin...
      include AASM

      aasm_initial_state :draft
      aasm_column :publication_status
      @@protected_publication_states=[:published]
      @@publication_states = [:draft,:published,:private]
      @@publication_states.each { |s| aasm_state s}

      # this needs to come after the class variable definition...
      cattr_accessor :publication_states

      aasm_event :publish do
        transitions :to => :published, :from => [:draft]
      end

      aasm_event :un_publish do
        transitions :to => :draft, :from => [:published]
      end

      named_scope :published,
      {
        :conditions =>{:publication_status => "published"}
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
    end
  end
end
