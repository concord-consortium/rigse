class PortalToVersion20090706182634 < ActiveRecord::Migration
  def self.up
    Engines.plugins["portal"].migrate(20090706182634)
  end

  def self.down
    Engines.plugins["portal"].migrate(20090704180532)
  end
end
