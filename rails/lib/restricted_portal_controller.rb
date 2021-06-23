module RestrictedPortalController
  # restrict access to sensitive routes to manager
  def self.included(clazz)
    # include methods like require_roles
    include RestrictedController
     clazz.class_eval {
       before_action :manager, :only => :index

       protected
       # must define current_clazz in calling controller class
       def teacher_admin
         force_signin unless current_clazz.is_teacher?(current_visitor) || current_visitor.has_role?('admin')
       end

       def student_teacher_admin
         force_signin unless current_clazz.is_student?(current_visitor) || current_clazz.is_teacher?(current_visitor) ||
                   current_visitor.has_role?('admin')
       end

       def student_teacher_or_admin
         force_signin unless current_clazz.is_student?(current_visitor) || current_clazz.is_teacher?(current_visitor) ||
                   current_visitor.has_role?('admin')
       end
     }
   end
end
