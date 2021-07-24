class AddDefaultTruePopupToExternalAcitivities < ActiveRecord::Migration[5.1]
  def up
     change_column :external_activities, :popup, :boolean, :default => true
     ExternalActivity.where(:popup => nil).map { |e| e.update_attribute(:popup,true) }
  end
  def down
    change_column :external_activities, :popup, :boolean
  end

end
