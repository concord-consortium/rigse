module ContainerController
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def toggle_controller_for(toggle_model_name)
      model_name = toggle_model_name.to_s.singularize
      class_name = model_name.camelcase
      eval_text = <<-DONE_EVAL
        protected
        def toggle_enabled(isit)
          #{model_name} = #{class_name}.find(params[:id])
          results = :bad_request
          if #{model_name}.changeable?(current_user)
            #{model_name}.is_enabled=isit
            if #{model_name}.save
              results = :ok
            end
          end
          head results
        end
        public 

        def enable
          toggle_enabled(true)
        end

        def disable
          toggle_enabled(false)
        end
      DONE_EVAL
      class_eval(eval_text)
    end
  end
end

