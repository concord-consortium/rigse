class AddActiveFieldToClazz < ActiveRecord::Migration
  def self.up
    add_column :portal_clazzes, :active, :boolean, :default=>true
    portal_clazzes = Portal::Clazz.find(:all)
    portal_clazzes.each do |clazz|
      clazz.active = true 
      clazz.save!
    end
  end

  def self.down
    remove_column :portal_clazzes, :active
  end 
end