module RestrictedPortalController
  
  # restrict access to sensitive routes to manager 
  def self.included(clazz)

     clazz.class_eval {
       before_filter :manager, :only => :index

       protected  
       
       def manager
         require_roles('manager','admin','district_admin')
       end
       
       def admin_only  
         require_roles('admin')
       end
       
       protected  

       def admin_or_config
          redirect_home unless current_user.has_role?('admin') || request.format == :config
       end

       # must define current_clazz in calling controller class
       def teacher_admin_or_config
         redirect_home unless current_clazz.is_teacher?(current_user) || current_user.has_role?('admin') || request.format == :config
       end
       
       def require_roles(*roles)
         redirect_home unless (current_user != nil &&  current_user.has_role?(*roles))
       end         
       
       def redirect_home(message = "Please log in as an administrator")
         flash[:notice] = "Please log in as an administrator" 
         redirect_to(:home)
       end
       
     }

   end
   
end
