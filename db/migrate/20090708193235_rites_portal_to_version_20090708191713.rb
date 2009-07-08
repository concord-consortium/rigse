class RitesPortalToVersion20090708191713 < ActiveRecord::Migration
  def self.up
    Engines.plugins["rites_portal"].migrate(20090708191713)
  end

  def self.down
    Engines.plugins["rites_portal"].migrate(20090706182634)
  end
end
