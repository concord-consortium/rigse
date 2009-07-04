class RitesPortalToVersion20090704180532 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090704180532)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(20090704075501)
  end
end
