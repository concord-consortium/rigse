class CreatePortalCountries < ActiveRecord::Migration
  def change
    create_table :portal_countries do |t|
      t.string  :name,             :limit => 255
      t.string  :formal_name,      :limit => 255
      t.string  :capital,          :limit => 255
      t.string  :two_letter,       :limit => 2
      t.string  :three_letter,     :limit => 3
      t.string  :tld,              :limit => 255
      t.integer :iso_id,           :limit => 255
      
      t.timestamps
    end

    add_index :portal_countries, :iso_id
    add_index :portal_countries, :two_letter
    add_index :portal_countries, :name
  end
end

