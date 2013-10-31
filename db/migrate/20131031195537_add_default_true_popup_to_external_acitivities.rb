class AddDefaultTruePopupToExternalAcitivities < ActiveRecord::Migration
  class ExternalActivity < ActiveRecord::Base
     attr_accessible :popup
  end
  def up
     change_column :external_activities, :popup, :boolean, :default => true
     ExternalActivity.where(:popup => nil).map { |e| e.update_attribute(:popup,true) }
  end
  def down
    change_column :external_activities, :popup, :boolean
  end

end
