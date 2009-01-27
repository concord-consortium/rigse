class Rigse < ActiveRecord::Migration
  def self.up
    create_table :domains do |t|
      t.string :name
      t.string :key
    end

    create_table :knowledge_statements do |t|
      t.integer :domain_id
      t.integer :number
      t.string  :statement
    end

    create_table :assessment_targets do |t|
      t.integer :knowledge_statement_id
      t.integer :unifying_theme_id
      t.integer :number
      t.string  :target
      t.string  :grade_span
    end

    create_table :grade_span_expectations do |t|
      t.integer :assessment_target_id
      t.string  :grade_span
    end

    create_table :expectation_stems do |t|
      t.integer :grade_span_expectation_id
      t.string  :stem
    end

    create_table :expectations do |t|
      t.integer :expectation_stem_id
      t.string  :ordinal
      t.string  :expectation
    end

    create_table :unifying_themes do |t|
      t.string  :name
      t.string  :key
    end

    create_table :big_ideas do |t|
      t.integer :unifying_theme_id
      t.string  :idea
    end
  end

  def self.down
    drop_table :domains
    drop_table :knowledge_statements
    drop_table :assessment_targets
    drop_table :grade_span_expectations 
    drop_table :expectation_stems 
    drop_table :expectations
    drop_table :unifying_themes 
    drop_table :big_ideas
  end
end
