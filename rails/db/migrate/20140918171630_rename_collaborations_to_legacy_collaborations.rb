class RenameCollaborationsToLegacyCollaborations < ActiveRecord::Migration
  def change
    rename_table :collaborations, :legacy_collaborations
  end
end
