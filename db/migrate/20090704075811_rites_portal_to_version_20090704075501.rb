class RitesPortalToVersion20090704075501 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090704075501)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(20090701153613)
  end
end
