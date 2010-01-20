class InvestigationObserver < ActiveRecord::Observer
  def after_update(investigation)
    otml_path = "#{ActionController::Base.page_cache_directory}/investigations/#{investigation.id}.otml"
    File.delete(otml_path) if File.exists?(otml_path)
    teacher_otml_path = "#{ActionController::Base.page_cache_directory}/investigations/teacher/#{investigation.id}.otml"
    File.delete(teacher_otml_path) if File.exists?(teacher_otml_path)
  end
end