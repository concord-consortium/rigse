class RitesPortalToVersion20090630133011 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090630133011)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(0)
  end
end
