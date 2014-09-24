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
end
