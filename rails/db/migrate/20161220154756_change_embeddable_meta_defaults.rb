class ChangeEmbeddableMetaDefaults < ActiveRecord::Migration

  def disable_all_feedback()
    execute "update portal_offering_embeddable_metadata set enable_text_feedback=false"
    execute "update portal_offering_embeddable_metadata set enable_score=false"
  end

  def up
    change_column :portal_offering_embeddable_metadata, :enable_text_feedback, :boolean, :default => false
    disable_all_feedback
  end

  def down
    change_column :portal_offering_embeddable_metadata, :enable_text_feedback, :boolean, :default => true
  end
end
