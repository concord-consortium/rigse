class AddDomainIdToPortalTeacher < ActiveRecord::Migration
  def self.up
    add_column :portal_teachers, :domain_id, :integer
  end

  def self.down
    remove_column :portal_teachers, :domain_id
  end
end
