module RestrictedBundleController
  
  # restrict access to admins 
  def self.included(clazz)
    include RestrictedController
    clazz.class_eval {
      # TODO: do console loggers use :bundle format too?
      # in the meantime, I have added the :except => rules to be sure.
      before_filter :admin_only, :except => [:new, :create]
    protected 
      def admin_only 
        unless (current_user != nil && current_user.has_role?('admin')) || request.format == :bundle
          flash[:notice] = "Please log in as an administrator" 
          redirect_to(:home)
        end
      end
    }
  end
end
