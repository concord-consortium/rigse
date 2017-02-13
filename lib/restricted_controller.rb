module RestrictedController

  def self.included(clazz)
     clazz.class_eval {

       protected

       def manager
         require_roles('manager','admin','district_admin')
       end

       def manager_or_researcher
         require_roles('manager','admin','researcher')
       end

       def admin_only
         require_roles('admin')
       end

       def admin_or_config
          force_signin unless current_visitor.has_role?('admin') || request.format == :config
       end

       def require_roles(*roles)
         force_signin unless (current_visitor != nil &&  current_visitor.has_role?(*roles))
       end

       def force_signin
         raise Pundit::NotAuthorizedError
       end

     }

   end
end
