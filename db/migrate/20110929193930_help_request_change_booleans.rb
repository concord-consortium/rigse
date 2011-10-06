class HelpRequestChangeBooleans < ActiveRecord::Migration
  def self.up
    change_table :help_requests do |t|
        t.change :all_computers, :string
    end
  end

  def self.down
    change_table :help_requests do |t|
        t.change :all_computers, :boolean
    end
  end
end
