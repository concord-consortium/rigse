class CreateAutoExternalActivityRules < ActiveRecord::Migration[8.0]
  def change
    create_table :auto_external_activity_rules do |t|
      t.string :name
      t.string :slug
      t.string :description
      t.text :allow_patterns
      t.references :user

      t.timestamps
    end

    add_index :auto_external_activity_rules, :slug, unique: true, name: 'auto_external_activity_rules_uniq_idx'

    create_table :auto_external_activity_rules_external_reports, id: false do |t|
      t.references :auto_external_activity_rule
      t.references :external_report
    end

    add_index :auto_external_activity_rules_external_reports,
      [:auto_external_activity_rule_id, :external_report_id],
      name: "auto_external_activity_rules_reports"
  end
end
