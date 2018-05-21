class CreateMaterialProperties < ActiveRecord::Migration
  class Admin::Tag < ActiveRecord::Base
    self.table_name = 'admin_tags'
  end

  class Activity < ActiveRecord::Base
    self.table_name = 'activities'
    acts_as_taggable_on :material_properties
    has_many :external_activities, :as => :template
    belongs_to :investigation

    def is_template
      return external_activities.compact.length > 0
    end
  end

  class Investigation < ActiveRecord::Base
    self.table_name = 'investigations'
    acts_as_taggable_on :material_properties
    has_many :activities, :order => :position
    has_many :external_activities, :as => :template

    def is_template
      return true if activities.detect { |a| a.is_template }
      return external_activities.compact.length > 0
    end
  end

  def up
    Admin::Tag.create!(scope: 'material_properties', tag: 'Requires download')

    Investigation.all.select{|i| !i.is_template }.each do |i|
      i.material_property_list.add('Requires download')
      i.save
    end

    Activity.all.select{|a| !a.is_template && !a.investigation }.each do |a|
      a.material_property_list.add('Requires download')
      a.save
    end

    # Rewrite all the tags we just created to point to the correct type 'Investigation' instead of 'CreateMaterialProperties::Investigation'
    ActsAsTaggableOn::Tagging.where(taggable_type: 'CreateMaterialProperties::Investigation').update_all('taggable_type = "Investigation"')
    ActsAsTaggableOn::Tagging.where(taggable_type: 'CreateMaterialProperties::Activity').update_all('taggable_type = "Activity"')

    reindex
  end

  def down
    Admin::Tag.where(scope: 'material_properties').destroy_all

    ActsAsTaggableOn::Tagging.where(context: 'material_properties').destroy_all

    reindex
  end

  # Adapted from the sunspot:reindex rake task
  # 2015-12-07 NP: UPDATE:
  # This migration will break for developers who haven't run this migration yet,
  # but also have other new pending model migrations.

  # New models that have added to app/models/** expect that their tables exist.
  # Loading those new models here, will throw exceptions. (As happened to me)
  def reindex
    if ENV["REINDEX_SOLR"].present? # We would need to set this explicitly to re-index
      Sunspot.session = Sunspot::SessionProxy::Retry5xxSessionProxy.new(Sunspot.session)
      reindex_options = { :batch_commit => false }
      Dir.glob(Rails.root.join('app/models/**/*.rb')).each { |path| require path }
      sunspot_models = Sunspot.searchable
      sunspot_models.each do |model|
        model.solr_reindex(reindex_options)
      end
    end
  end
end
