class RemoveOldColunsFromInvestigation < ActiveRecord::Migration
  def self.up
    remove_column :investigations, :reflection
    remove_column :investigations, :assessment
    remove_column :investigations, :procedures_closure
    remove_column :investigations, :procedures_engagement
    remove_column :investigations, :procedures_opening
    remove_column :investigations, :opportunities
    remove_column :investigations, :objectives
    remove_column :investigations, :context
  end

  def self.down
    add_column :investigations, :context, :text
    add_column :investigations, :objectives, :text
    add_column :investigations, :opportunities, :text
    add_column :investigations, :procedures_opening, :text
    add_column :investigations, :procedures_engagement, :text
    add_column :investigations, :procedures_closure, :text
    add_column :investigations, :assessment, :text
    add_column :investigations, :reflection, :text
  end
end
