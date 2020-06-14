class AddHaveConsentToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :of_consenting_age, :boolean, :default => false
    add_column :users, :have_consent, :boolean, :default      => false
  end

  def self.down
    remove_column :users, :have_consent
    remove_column :users, :of_consenting_age
  end
end
