class RitesPortalToVersion20090703050010 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090701153613)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(20090701153612)
  end
end
