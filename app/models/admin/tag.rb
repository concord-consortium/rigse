class Admin::Tag < ActiveRecord::Base
  set_table_name "admin_tags"

  self.extend SearchableModel
  @@searchable_attributes = %w{scope tag}

  include Changeable

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Tag"
    end

    def search_list(options)
      name = options[:scope]
      tags = Admin::Tag.like(name)
    end
  end

  def name
    "#{scope}:#{tag}"
  end
end
