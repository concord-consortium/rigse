class AddLegacyLaraUrl < ActiveRecord::Migration[6.1]
  def change
    add_column :external_activities, :legacy_lara_url, :text, :default => nil
  end
end
