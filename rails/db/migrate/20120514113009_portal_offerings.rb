class PortalOfferings < ActiveRecord::Migration
  def self.up
    add_column :portal_offerings, :position, :integer, :default=>0 
    clazzes = Portal::Clazz.find(:all)
    clazzes.each do|clazz|
      portal_offerings = clazz.offerings
      position = 1
      portal_offerings.each do|portal_offering|
        puts "position=" + position.to_s
        portal_offering.position = position
        unless portal_offering.save
          down
          raise 'Error. Please revert'
        end
        position += 1
      end
    end
  end

  def self.down
    remove_column :portal_offerings, :position
  end
end
