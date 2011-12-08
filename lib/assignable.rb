class Assignable
  class <<self
    def all_assignables(opts = {})
      top_level_assignables(opts) + other_assignables(opts)
    end

    def top_level_assignables(opts = {})
      assignables = []
      top_level_assignable_types.each do |type|
        assignables.concat type.search_list(opts)
      end
      return assignables
    end

    def other_assignables(opts = {})
      assignables = []
      other_assignable_types.each do |type|
        assignables.concat type.search_list(opts)
      end
      return assignables
    end

    def all_assignable_types
      top_level_assignable_types + other_assignable_types
    end

    def top_level_assignable_types
      [TOP_LEVEL_CONTAINER_CLASS]
    end

    def other_assignable_types
      # Not so great to be switching behavior based on theme,
      # but at least it'll give us a start at abstracting this
      # out of the controllers and models.
      case APP_CONFIG[:theme]
      when 'itsisu'
        return itsisu_other_assignable_types
      else
        return default_other_assignable_types
      end
    end

    private

    def default_other_assignable_types
      [ResourcePage, ExternalActivity, Page]
    end

    def itsisu_other_assignable_types
      [Page]
    end
  end
end
