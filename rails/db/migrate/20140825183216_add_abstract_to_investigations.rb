class AddAbstractToInvestigations < ActiveRecord::Migration[5.1]
  def change
    add_column :investigations, :abstract, :text
  end
end
