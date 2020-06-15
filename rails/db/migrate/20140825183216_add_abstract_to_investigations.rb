class AddAbstractToInvestigations < ActiveRecord::Migration
  def change
    add_column :investigations, :abstract, :text
  end
end
