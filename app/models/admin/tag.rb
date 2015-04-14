class Admin::Tag < ActiveRecord::Base
  self.table_name = "admin_tags"

  self.extend SearchableModel
  @@searchable_attributes = %w{scope tag}

  include Changeable

  class <<self
    def searchable_attributes
      @@searchable_attributes
    end


    def search_list(options)
      name = options[:scope]
      tags = Admin::Tag.like(name)
    end

    def fetch_tag(options)
      Admin::Tag.where(scope: options[:scope], tag: options[:tag])
    end
  end

  def name
    "#{scope}:#{tag}"
  end
end
