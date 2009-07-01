class RitesPortalToVersion20090701153612 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090701153612)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(20090630133011)
  end
end
