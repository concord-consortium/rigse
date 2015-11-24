module Cohorts

  def self.included(clazz)
    clazz.class_eval do
      has_many :cohort_items, :class_name => 'Admin::CohortItem', :as => :item
      has_many :cohorts, :class_name => 'Admin::Cohort', :through => :cohort_items, :foreign_key => "admin_cohort_id"
    end
  end

  def set_cohorts_by_id(ids=[])
    self.cohorts = Admin::Cohort.find_all_by_id(ids)
  end

  def cohort_fullnames
    self.cohorts.map {|c| c.fullname}
  end

end
