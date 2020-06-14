module TeacherGuideHelper

  protected
  def can_view_teacher_guide?(user=current_user)
    return false unless user
    return true if user.has_role? "admin"
    return true if user.has_role? "manager"
    return user.portal_teacher
  end

  public
  def teacher_guide_link(thing)
    return "" unless thing.respond_to? :teacher_guide_url
    return "" unless can_view_teacher_guide?(current_user)
    return "" if thing.teacher_guide_url.blank?
    return(link_to "Teacher guide", thing.teacher_guide_url, :class=>'button', :target => "_blank")
  end
  
end
