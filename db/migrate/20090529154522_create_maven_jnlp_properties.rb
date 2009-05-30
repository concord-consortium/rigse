class CreateMavenJnlpProperties < ActiveRecord::Migration
  def self.up
    create_table :maven_jnlp_properties do |t|
      t.string :uuid
      t.string :name
      t.string :value
      t.string :os

      t.timestamps
    end
  end

  def self.down
    drop_table :maven_jnlp_properties
  end
end
