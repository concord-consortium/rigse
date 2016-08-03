module Saveable::Saveable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def possible_types
      @possible_types ||= get_possible_types
    end
    def embeddable_type(instance)
      @embeddable_type ||= get_embeddable_type(instance)
    end
    def get_possible_types
      @possible_types = ResponseTypes.reportable_types.map{ |t|  {:klass => t, :str => t.to_s.demodulize.underscore} }
      @possible_types
    end
    def get_embeddable_type(instance)
      @embeddable_type = possible_types.detect {|type| instance.respond_to? type[:str]}
      @embeddable_type
    end
  end

  def embeddable
    self.send(self.class.embeddable_type(self)[:str])
  end

  def submitted?
    # Note that we consider regular questions (not required) as submitted when
    # they have any answer available. Required questions have to have the last
    # answer explicitly marked as final (submitted).
    if embeddable.is_required
      answered? && answers.last.is_final
    else
      answered?
    end
  end

  def answer
    if answered?
      answers.last.answer
    else
      'not answered'
    end
  end

  def answered?
    answers.length > 0
  end


  def current_feedback
    if answered? && answers.last.respond_to?(:feedback)
      answers.last.feedback
    else
      nil
    end
  end

  def current_score
    if answered? && answers.last.respond_to?(:score)
      answers.last.score
    else
      nil
    end
  end

  def needs_review?
    if answered? && answers.last.respond_to?(:has_been_reviewed?)
      ! answers.last.has_been_reviewed?
    else
      false
    end
  end

  # add_feedback to last answer only.
  def add_feedback(feedback_opts)
    return unless answers.size > 0
    opts = {}
    opts[:score]             = feedback_opts['score']    if feedback_opts.has_key?('score')
    opts[:feedback]          = feedback_opts['feedback'] if feedback_opts.has_key?('feedback')
    opts[:has_been_reviewed] = feedback_opts['has_been_reviewed'] if feedback_opts.has_key?('has_been_reviewed')
    answers.last.update_attributes(opts)
  end
end
