class CreateMavenJnlpIcons < ActiveRecord::Migration[5.1]
  def self.up
    create_table :maven_jnlp_icons do |t|
      t.string :uuid
      t.string :name
      t.string :href
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_icons
  end
end
