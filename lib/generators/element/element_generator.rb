class ElementGenerator < Rails::Generator::NamedBase
  default_options :skip_timestamps => false, :force_plural => false

  attr_reader   :controller_name,
                :controller_class_path,
                :controller_file_path,
                :controller_class_nesting,
                :controller_class_nesting_depth,
                :controller_class_name,
                :controller_underscore_name,
                :controller_singular_name,
                :controller_plural_name
  alias_method  :controller_file_name,  :controller_underscore_name
  alias_method  :controller_table_name, :controller_plural_name

  def initialize(runtime_args, runtime_options = {})
    super

    if @name == @name.pluralize && !options[:force_plural]
      logger.warning "Plural version of the model detected, using singularized version.  Override with --force-plural."
      @name = @name.singularize
    end

    @controller_name = @name.pluralize
    @erb_single = @name.underscore
    @erb_pural = @controller_name.underscore

    base_name, @controller_class_path, @controller_file_path, @controller_class_nesting, @controller_class_nesting_depth = extract_modules(@controller_name)
    @controller_class_name_without_nesting, @controller_underscore_name, @controller_plural_name = inflect_names(base_name)
    @controller_singular_name=base_name.singularize
    if @controller_class_nesting.empty?
      @controller_class_name = @controller_class_name_without_nesting
    else
      @controller_class_name = "#{@controller_class_nesting}::#{@controller_class_name_without_nesting}"
    end
  end

  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions("#{controller_class_name}Controller")
      m.class_collisions(class_name)

      # Controller, helper, views, test and stylesheets directories.
      m.directory(File.join('app/models', class_path))
      m.directory(File.join('app/controllers', controller_class_path))
      m.directory(File.join('app/views', controller_class_path, controller_file_name))

      # Model class
      m.template 'model.rb',      File.join('app/models', class_path, "#{file_name}.rb")
      
      m.template(
        'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      )
      m.route_resources controller_file_name
      
      # views:
      for action in scaffold_views
        m.template(
          "view_#{action}.html.haml",
          File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.haml")
        )
      end
      
      # partials:
      for partial in partials
        m.template(
          "_#{partial}.html.haml",
          File.join('app/views', controller_class_path, controller_file_name, "_#{partial}.html.haml")
        )
      end
      
      #special case:
        m.template(
          "_element.html.haml",
          File.join('app/views', controller_class_path, controller_file_name, "_#{singular_name}.html.haml")
        )
    end
  end

  protected
    # Override with your own usage banner.
    def banner
      "Usage: #{$0} element ModelName [field:type, field:type]"
    end

    def add_options!(opt)
      opt.separator ''
      opt.separator 'Options:'
      opt.on("--skip-timestamps",
             "Don't add timestamps to the migration file for this model") { |v| options[:skip_timestamps] = v }
      opt.on("--skip-migration",
             "Don't generate a migration file for this model") { |v| options[:skip_migration] = v }
      opt.on("--force-plural",
             "Forces the generation of a plural ModelName") { |v| options[:force_plural] = v }
    end

    def scaffold_views
      %w[ index show new edit ]
    end

    def partials
      %w[ remote_form show]
    end
    
    def model_name
      class_name.demodulize
    end
end
