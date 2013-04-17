module MockData
  
  #UUID_PATTERN = /^00000000-0000-0000-0000-/
  UUID_LIKE_PATTERN = '00000000-0000-0000-0000-%'
  
  def self.delete_default_data
    delete_default_learners
    delete_default_study_materials
    delete_default_resource_pages
    delete_default_pages
    delete_default_questions
    delete_default_clazzes
    delete_default_users
    delete_default_courses
    delate_default_roles
    delete_default_schools
    delete_default_grade_levels
    delete_default_districts
    delete_default_projects
  end #end of reset_default_data
  
  
  # helper methods
  
  def self.delete_learner_response_data(learner)
    Saveable::ImageQuestion.find_all_by_learner_id(learner.id).each do |r|
      r.answers.each do |s|
        s.blob.destroy
        s.destroy
      end
      r.destroy
    end
  end
  
  def self.delete_default_learners
    portal_learners = Portal::Learner.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN) 
    portal_learners.each do |l|
      delete_learner_response_data(l)
      l.destroy
    end
  end
  
  def self.delete_default_study_materials
    investigations = Investigation.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN) 
    investigations.each do |i|
      i.destroy
    end
    
    activities = Activity.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN) 
    activities.each do |a|
      a.destroy
    end
    
    external_activities = ExternalActivity.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    external_activities.each do |e|
      e.destroy
    end
  end
  
  def self.delete_default_resource_pages
    resource_pages = ResourcePage.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    resource_pages.each do |rp|
      rp.destroy
    end
  end
  
  def self.delete_default_pages
    pages = Page.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    pages.each do |p|
      p.destroy
    end
  end
  
  def self.delete_default_questions
    mcqs = Embeddable::MultipleChoice.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    mcqs.each do |mcq|
      mcq.destroy
    end
    
    img_qs = Embeddable::ImageQuestion.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    img_qs.each do |img_q|
      img_q.destroy
    end
  end
  
  def self.delete_default_clazzes
    clazzes = Portal::Clazz.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    clazzes.each do |c|
      c.destroy
    end
  end
  
  def self.delete_default_users
    users = User.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    users.each do |u|
      u.destroy
    end
  end
  
  def self.delete_default_courses
    courses = Portal::Course.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    courses.each do |c|
      c.destroy
    end
  end
  
  def self.delate_default_roles
    roles = Role.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    roles.each do |ro|
      ro.destroy
    end
  end
  
  def self.delete_default_schools
    schools = Portal::School.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    schools.each do |s|
      s.destroy
    end
  end
  
  def self.delete_default_grade_levels
    grades = Portal::Grade.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    grades.each do |g|
      g.destroy
    end
  end
  
  def self.delete_default_districts
    districts = Portal::District.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    districts.each do |d|
      d.destroy
    end
  end
  
  def self.delete_default_projects
    admin_projects = Admin::Project.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    admin_projects.each do |s|
      s.destroy
    end
  end

end #end of MockData 