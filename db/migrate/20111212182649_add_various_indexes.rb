class AddVariousIndexes < ActiveRecord::Migration
  def self.up
    add_index :investigations, :publication_status, :length => 10
    add_index :investigations, :user_id
    add_index :investigations, :name

    begin
      add_index :activities, [:publication_status, :is_exemplar], :length => {:publication_status => 10, :is_exemplar => 1}
    rescue
      add_index :activities, :publication_status, :length => 10
    end
    add_index :activities, :user_id
    add_index :activities, :name

    add_index :sections, :publication_status, :length => 10

    add_index :pages, :publication_status, :length => 10
    add_index :pages, :user_id
    add_index :pages, :name

    add_index :portal_offerings, :clazz_id

    add_index :portal_school_memberships, :school_id

    #adjust some index lengths for existing indexes
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings, [:taggable_id, :taggable_type, :context], :length => {:taggable_type => 15, :context => 15}

    remove_index :settings, [:scope_type, :scope_id, :name]
    add_index :settings, [:scope_type, :scope_id, :name], :length => {:scope_type => 15, :name => 15}

    remove_index :portal_school_memberships, :name => 'member_type_id_index'
    add_index :portal_school_memberships, [:member_type, :member_id], :name => 'member_type_id_index', :length => {:member_type => 15}
  end

  def self.down
    remove_index :investigations, :publication_status
    remove_index :investigations, :user_id
    remove_index :investigations, :name

    if index_exists?(:activities, index_name(:activities, [:publication_status, :is_exemplar]), nil)
      remove_index :activities, [:publication_status, :is_exemplar]
    else
      remove_index :activities, :publication_status
    end
    remove_index :activities, :user_id
    remove_index :activities, :name

    remove_index :sections, :publication_status

    remove_index :pages, :publication_status
    remove_index :pages, :user_id
    remove_index :pages, :name

    remove_index :portal_offerings, :clazz_id
  end
end
