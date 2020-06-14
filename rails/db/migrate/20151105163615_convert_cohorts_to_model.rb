class ConvertCohortsToModel < ActiveRecord::Migration
  def up
    create_table :admin_cohorts do |t|
      t.integer :project_id
      t.string  :name
    end
    add_index :admin_cohorts, [:project_id, :name], :unique => true

    create_table :admin_cohort_items do |t|
      t.integer :admin_cohort_id
      t.integer :item_id
      t.string  :item_type
    end

    # add all existing cohorts to all projects
    cohort_tags = Admin::Tag.where(:scope => 'cohorts')
    projects = Admin::Project.all
    projects.each do |project|

      # create each cohort
      cohort_tags.each do |cohort_tag|
        cohort = Admin::Cohort.new
        cohort.project = project
        cohort.name = cohort_tag.tag
        cohort.save

        # add each tagged cohort item
        ActsAsTaggableOn::Tagging.where(:context => 'cohorts').each do |tagging|
          if tagging.tag.name == cohort.name
            item = Admin::CohortItem.new
            item.cohort = cohort
            item.item = tagging.taggable
            item.save
          end
        end
      end
    end

    # TODO: remove existing cohorts
  end

  def down
    drop_table :admin_cohorts
    drop_table :admin_cohort_items
  end
end
