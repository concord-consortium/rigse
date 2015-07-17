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

    def add_new_admin_tags(taggable, tag_type, tag_list)
      tag_list.each do |tag|
        new_admin_tag = {:scope => "#{tag_type}s", :tag => tag}
        if Admin::Tag.fetch_tag(new_admin_tag).size == 0
          admin_tag = Admin::Tag.new(new_admin_tag)
          admin_tag.save!
        end
        taggable.send("#{tag_type}_list").add(tag)
      end
    end 
  end

  def name
    "#{scope}:#{tag}"
  end
end
