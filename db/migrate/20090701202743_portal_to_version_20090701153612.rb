class PortalToVersion20090701153612 < ActiveRecord::Migration
  def self.up
    Engines.plugins["portal"].migrate(20090701153612)
  end

  def self.down
    Engines.plugins["portal"].migrate(0)
  end
end
