module TeacherGuideHelper

  protected
  def can_view_teacher_guide?(user=current_user)
    return false unless user  
    return true if user.has_role? "admin"
    return true if user.has_role? "manager"
    return user.teacher
  end

  public
  def teacher_guide_link(thing)
    return "" unless thing.respond_to? :teacher_guide_link
    return "" unless can_view_teacher_guide?(current_user)
    return link_to "teacher_guide", thing.teacher_guide_url
  end
  
end
