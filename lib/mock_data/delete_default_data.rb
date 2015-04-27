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
    delete_default_settings
    delete_default_materials_collections
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
    puts <<-HEREDOC
    
    Deleting default learners
    
    HEREDOC
    
    portal_learners = Portal::Learner.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN) 
    portal_learners.each do |l|
      delete_learner_response_data(l)
      l.destroy
    end
  end
  
  def self.delete_default_study_materials
    puts <<-HEREDOC
    
    Deleting default study materials
    
    HEREDOC
    
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
    puts <<-HEREDOC
    
    Deleting resource pages
    
    HEREDOC
    
    resource_pages = ResourcePage.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    resource_pages.each do |rp|
      rp.destroy
    end
  end
  
  def self.delete_default_pages
    puts <<-HEREDOC
    
    Deleting default pages
    
    HEREDOC
    
    pages = Page.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    pages.each do |p|
      p.destroy
    end
  end
  
  def self.delete_default_questions
    puts <<-HEREDOC
    
    Deleting default questions
    
    HEREDOC
    
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
    puts <<-HEREDOC
    
    Deleting default classes
    
    HEREDOC
    
    clazzes = Portal::Clazz.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    clazzes.each do |c|
      c.destroy
    end
  end
  
  def self.delete_default_users
    puts <<-HEREDOC
    
    Deleting default users
    
    HEREDOC
    
    users = User.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    users.each do |u|
      u.destroy
    end
  end
  
  def self.delete_default_courses
    puts <<-HEREDOC
    
    Deleting default courses
    
    HEREDOC
    
    courses = Portal::Course.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    courses.each do |c|
      c.destroy
    end
  end
  
  def self.delate_default_roles
    puts <<-HEREDOC
    
    Deleting default roles
    
    HEREDOC
    
    roles = Role.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    roles.each do |ro|
      ro.destroy
    end
  end
  
  def self.delete_default_schools
    puts <<-HEREDOC
    
    Deleting default schools
    
    HEREDOC
    
    schools = Portal::School.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    schools.each do |s|
      s.destroy
    end
  end
  
  def self.delete_default_grade_levels
    puts <<-HEREDOC
    
    Deleting default grade levels
    
    HEREDOC
    
    grades = Portal::Grade.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    grades.each do |g|
      g.destroy
    end
  end
  
  def self.delete_default_districts
    puts <<-HEREDOC
    
    Deleting default districts
    
    HEREDOC
    
    districts = Portal::District.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    districts.each do |d|
      d.destroy
    end
  end
  
  def self.delete_default_settings
    puts <<-HEREDOC
    
    Deleting default settings
    
    HEREDOC
    
    admin_settings = Admin::Settings.where('uuid LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    admin_settings.each do |s|
      s.destroy
    end
  end

  def self.delete_default_materials_collections
    puts <<-HEREDOC

    Deleting default materials collections

    HEREDOC

    materials_collections = MaterialsCollection.where('description LIKE :prefix', :prefix => UUID_LIKE_PATTERN)
    materials_collections.each do |m|
      m.destroy
    end
  end

end #end of MockData 
