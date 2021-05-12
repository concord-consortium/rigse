class RenameCollaborationsToLegacyCollaborations < ActiveRecord::Migration[5.1]
  def change
    rename_table :collaborations, :legacy_collaborations
  end
end
