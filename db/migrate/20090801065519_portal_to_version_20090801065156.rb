class PortalToVersion20090801065156 < ActiveRecord::Migration
  def self.up
    Engines.plugins["portal"].migrate(20090801065156)
  end

  def self.down
    Engines.plugins["portal"].migrate(20090722180312)
  end
end
