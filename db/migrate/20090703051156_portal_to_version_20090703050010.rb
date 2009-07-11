class PortalToVersion20090703050010 < ActiveRecord::Migration
  def self.up
    Engines.plugins["portal"].migrate(20090701153613)
  end

  def self.down
    Engines.plugins["portal"].migrate(20090701153612)
  end
end
