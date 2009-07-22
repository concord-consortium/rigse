class PortalToVersion20090722180312 < ActiveRecord::Migration
  def self.up
    Engines.plugins["portal"].migrate(20090722180312)
  end

  def self.down
    Engines.plugins["portal"].migrate(20090708191713)
  end
end
