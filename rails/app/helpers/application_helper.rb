module ApplicationHelper
  include Clipboard
  include Pundit

  def current_settings
    @_settings ||= Admin::Settings.default_settings
  end

  def top_level_container_name
    APP_CONFIG[:top_level_container_name] || "investigation"
  end

  #
  # dom_for_id generates a dom id value for any object that returns an integer when sent an "id" message
  #
  # This helper is normally used with ActiveRecord objects.
  #
  #   @model = Model.find(3)
  #   dom_id_for(@model)                        # => "model_3"
  #   dom_id_for(@model, :item)                 # => "item_model_3"
  #   dom_id_for(@model, :item, :textarea)      # => "item_textarea_model_3"
  #
  #   @scoped_model = OuterScope::InnerScope::Model.find(3)
  #   dom_id_for(@scoped_model)                 # => "outer_scope__inner_scope__model_3"

  def dom_id_for(component, *optional_prefixes)
    optional_prefixes.flatten!
    optional_prefixes.compact! unless optional_prefixes.empty?
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.underscore.clipboardify
    if component.is_a?(ApplicationRecord)
      id = component.id || Time.now.to_i
    else
      # this will be a temporary id, so it seems unlikely that these type of ids
      # should be really be generated, however there are some parts of the code
      # calling dom_id_for and passing a form object for example
      id = component.object_id
    end
    id_string = id.to_s
    "#{prefix}#{class_name}_#{id_string}"
  end

  def dom_class_for(component)
    component.class.name.underscore
  end

  def short_name(name)
    name.strip.downcase.gsub(/\W+/, '_')
  end


  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title_tag(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end

  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end

  def labeled_check_box(form, field, name=field.to_s.humanize)
    form.label(field, name) + "\n" + form.check_box(field)
  end

  # http://davidwparker.com/2008/11/12/simple-non-model-checkbox-in-rails/
  def check_box_tag_new(name, value = "1", options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => name, "value" => value }.update(options.stringify_keys)
    unless html_options["check"].nil?
      html_options["checked"] = "checked" if html_options["check"].to_i == 1
    end
    tag :input, html_options
  end

  def render_top_level_container_list_partial(locals)
    container = top_level_container_name.pluralize
    container_sym = top_level_container_name.pluralize.to_sym
    container_class = top_level_container_name.classify.constantize
    hide_print = locals.delete(:hide_print) || false
    if container_class.respond_to?(:search_list)
      render :partial => "#{container}/runnable_list", :locals => { container_sym => container_class.search_list(locals), :hide_print => hide_print }
    else
      render :partial => "#{container}/runnable_list", :locals => { container_sym => container_class.all, :hide_print => hide_print }
    end
  end

  def top_level_container_name_as_class_string
    container = top_level_container_name.pluralize
    container_sym = top_level_container_name.pluralize.to_sym
    container_class = top_level_container_name.classify
  end

  def render_partial_for(component,_opts={})
    class_name = component.class.name.underscore
    demodulized_class_name = component.class.name.delete_module.underscore_module

    opts = {
      :teacher_mode => false,
      :substitute    => nil,
      :partial      => 'show',
      :locals       => {}
    }
    opts.merge!(_opts)
    teacher_mode = opts[:teacher_mode]
    substitute = opts[:substitute]
    partial = "#{class_name.pluralize}/#{opts[:partial]}"
    locals = opts[:locals]
    locals[demodulized_class_name.to_sym] = substitute ? substitute : component
    locals[:teacher_mode] = teacher_mode
    render :partial => partial, :locals => locals
  end

  def render_show_partial_for(component, _opts = {})
    opts = {:teacher_mode => false, :substitute => nil}.merge(_opts)
    render_partial_for(component, opts)
  end

  def render_edit_partial_for(component,opts={})
    render_partial_for(component, {:partial => "remote_form"}.merge!(opts))
  end

  def edit_url_for(component, scope=false)
    if scope
      { :controller => component.class.name.pluralize.underscore,
        :action => :edit,
        :id  => component.id,
        :scope_type => scope.class,
        :scope_id =>scope.id}
    else
      { :controller => component.class.name.pluralize.underscore,
        :action => :edit,
        :id  => component.id,
        :container_type => @container_type,
        :container_id => @container_id }
    end
  end

  def edit_menu_for(component, form, options={:omit_cancel => true}, scope=false)
    component = (component.respond_to? :embeddable) ? component.embeddable : component
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_tag(:h3,{:class => 'menu'}) do
            haml_concat title_for_component(component, :id_prefix => 'edit')
          end
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          haml_tag :ul, {:class => 'menu'} do
            #if (component.changeable?(current_visitor))
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Save") }
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Cancel") } unless options[:omit_cancel]
            #end
          end
        end
      end
    end
  end

  def accordion_for(model, title, dom_prefix='', options={})
    show_hide_text = options[:show_hide_text]
    capture_haml do
      haml_tag :div, :id => dom_id_for(model, dom_prefix), :class => 'accordion_container' do
        haml_tag :div, :class => 'accordion_name' do
          haml_concat title
        end

        if show_hide_text
          haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_toggle"), :class => 'accordion_toggle_closed accordion_toggle' do
            haml_tag :span, :class => "accordion_show_hide_text" do
              haml_concat show_hide_text
            end
          end
        else
          haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_toggle"), :class => 'accordion_toggle_closed accordion_toggle'
        end

        unless options[:usage_count].blank?
          haml_tag :div, :class => 'accordion_count' do
            haml_concat options[:usage_count]
          end
        end

        haml_tag :div, :class => 'empty_break'
        haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_content"), :class => 'accordion_content', :style=>'display: none;' do
          if block_given?
            yield
          end
        end

      end
    end
  end

  def sort_dropdown(selected,keep = [])
    selected ||= Search::Alphabetical
    default_options = [ [Search::Oldest, "Oldest"], [Search::Newest, "Newest"], [Search::Alphabetical, "Alphabetical"], [Search::Popularity, "Popularity"] ]
    sort_options = (keep.size > 0 ? default_options.select{|o| keep.include?(o[0]) } : default_options)
    select nil, :sort_order, sort_options, {:selected => selected, :include_blank => false }
  end


  def learner_report_link_for(learner, action='report', link_text='Report ', title=nil)
    return "" unless learner.reportable?

    reportable_display_name = learner.class.display_name.downcase
    action_string = action.gsub('_', ' ')
    name = learner.name

    url = polymorphic_url(learner, :action => action)
    if title.nil?
      title = "Display a #{action_string} for the #{reportable_display_name}: '#{name}' in a new browser window."
    end
    link_to(link_text, url, :target => '_blank', :title => title)
  end

  def report_link_for(reportable, link_text='Report ', title=nil)
    return "" if reportable.respond_to?('reportable?') && !reportable.reportable?
    url = report_portal_offering_path(reportable.id)
    link_to link_text, url, :target => '_blank', :title => title
  end

  def activation_toggle_link_for(activatable, action='activate', link_text='Activate', title=nil)
    activatable_display_name = activatable.class.display_name.downcase
    action_string = action.gsub('_', ' ')
    url = polymorphic_url(activatable, :action => action)
    if title.nil?
      title = "#{action_string} the #{activatable_display_name}: '#{activatable.name}'."
    end
    link_to(link_text, url, :title => title)
  end

  def edit_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_text = params.delete(:link_text) || "edit "
    url = polymorphic_url(component, :action => :edit, :params => params)
    link_button("edit.png", url) +
    link_to(link_text, url,
        :title => "edit the #{component_display_name}: '#{name}'")
  end

  def duplicate_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    text = params[:text] || 'duplicate'
    name = component.name
    url = polymorphic_url(component, :action => :duplicate, :params => params)
    link_button("itsi_copy.png", url,
      :title => "copy the #{component_display_name}: '#{name}'") +
    link_to(text, url)
  end


  def print_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_text = params.delete(:link_text) || "print #{component_display_name}"
    if params[:teacher_mode]
      link_text = "#{link_text} (with notes) "
    end
    params.merge!({:print => true})
    url = polymorphic_url(component,:params => params)
    link_button("print.png", url, :title => "print the #{component_display_name}: '#{name}'") +
    link_to(link_text,url, :target => '_blank')
  end



  def link_to_container(container, options={})
    link_to name_for_component(container, options), container, :class => 'container_link'
  end

  def title_for_component(component, options={})
    title = name_for_component(component, options)
    id = dom_id_for(component, options[:id_prefix], :title)
    if ::Rails.env == "development" || current_visitor.has_role?('admin')
      "<span id=#{id} class='component_title'>#{title}</span><span class='dev_note'> #{link_to(component.id, component)}</span>".html_safe
    else
      "<span id=#{id} class='component_title'>#{title}</span>".html_safe
    end
  end

  def name_for_component(component, options={})
    if options[:display_name]
      return options[:display_name]
    end
    name = ''
    unless options[:hide_component_name]
      if component.class.respond_to? :display_name
        name << component.class.display_name
      else
        name << component.class.name.humanize
      end
      if component.respond_to? :display_type
        name = "#{component.display_type} #{name}"
      end
      name << ': '
    end
    default_name = ''
    if component.class.respond_to?(:default_value)
      default_name = component.class.default_value('name')
    end
    name << case
      when component.id.nil? then "(new)"
      when component.name == default_name then ''
      when component.name then component.name
      else ''
    end
  end

  def sessions_learner_stat(learner)
    'n/a'
  end

  def report_details_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true, :type => :open_responses, :correctable => false }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(learner, options)
        end
      end
    end
  end


  def percent(count,max,precision = 1)
    return 0 if max < 1
    raw = (count/max.to_f)*100
    result = (raw*(10**precision)).round/(10**precision).to_f
  end

  def percent_str(count, max, precision = 1)
    return "" if max < 1
    number_to_percentage(percent(count,max,precision), :precision => precision)
  end

  def menu_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_activity_options' do
          haml_concat learner_report_link_for(learner, 'report', 'Report')
        end
        haml_tag :div, :class => 'action_menu_activity_title' do
          haml_concat title_for_component(learner, options)
          haml_tag :span, :class => 'tiny' do
            haml_concat sessions_learner_stat(learner)
          end
        end
      end
    end
  end

  def lara_report_link(offering)
    if offering.runnable.kind_of?(ExternalActivity)
      url      = offering.runnable.url
      uri      = URI.parse(url)
      learners = offering.learner_ids.join(",")
      students = offering.learners.map { |l| "#{l.id}:#{l.user.login}" }.join(",")
      students = URI.escape(students)
      learners = URI.escape(learners)
      report_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/runs/details?learners=#{learners}&students=#{students}"
      haml_concat " | "
      haml_concat link_to("LARA Run report", report_url, {:target => "_blank"} )
    end
  end


  def link_button(image,url,options={})
    defaults = {
      :class      => 'rollover'
    }
    options = defaults.merge(options)
    link_to image_tag(image, :alt=>options[:title]) , url, options
  end

  def tab_for(component, options={})
    if(options[:active])
      "<li id=#{dom_id_for(component, :tab)} class='tab active'>#{link_to component.name, component, :class => 'active'}</li>".html_safe
    else
      "<li id=#{dom_id_for(component, :tab)} class='tab'>#{link_to component.name, component}</li>".html_safe
    end
  end

  # expects styles to contain space seperated list of style classes.
  def style_for_teachers(component,style_classes=[])
    if (for_teacher_only?(component))
      style_classes << 'teacher_only' # funny, just adding a style text
    end
    return style_classes
  end


  def style_for_item(component,style_classes=[])
    style_classes << 'item' << 'selectable' << 'item_selectable'
    if (component.respond_to? 'changeable?') && (component.changeable?(current_visitor))
      style_classes << 'movable'
    end
    style_classes = style_for_teachers(component,style_classes)
    return style_classes.join(" ")
  end

  def simple_div_helper_that_yields
    capture_haml do
      haml_tag :div, :class => 'simple_div' do
        if block_given?
          haml_concat yield
        end
      end
    end
  end

  def already_rendered?(thing)
    return @render_scope_additional_objects && @render_scope_additional_objects.include?(thing)
  end

  def mark_rendered(thing)
    @render_scope_additional_objects ||= []
    @render_scope_additional_objects << thing
  end

  def in_render_scope?(thing)
    return true if thing == nil
    if already_rendered?(thing)
      return true
    end

    if @render_scope
      if @render_scope.respond_to?("page_elements")
        embeddables = @render_scope.page_elements.collect{|pe| pe.embeddable}.uniq
        if embeddables.include?(thing)
          return true
        end
      end
    end
    return false
  end

  def render_scoped_reference(thing)
    return "" if thing == nil
    if in_render_scope?(thing)
      capture_haml do
        haml_tag :object, :refid => ot_refid_for(thing)
      end
    else
      render_show_partial_for(thing)
    end
  end

  #
  # is a component viewable only by teacher?
  # cascading logic.
  # TODO: generic container-based method-forwarding mechanism
  #
  def for_teacher_only?(thing)
    if (thing.respond_to?("teacher_only?") && thing.teacher_only?)
      return true;
    end
    if thing.respond_to? :parent
      while thing = thing.parent
        if thing.respond_to? :teacher_only?
          if thing.teacher_only?
            return true
          end
        end
      end
    end
    return false
  end

  def render_project_info
    unless @rendered_project_info
      render_themed_partial("home/project_info")
      @rendered_project_info = true
    end
  end

  def add_top_menu_item(link)
    @top_menu_items ||= []
    @top_menu_items << link
  end

  def runnable_list(options)
    Investigation.search_list(options)
  end

  def students_in_class(all_students)
    all_students.to_a.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

#            Welcome
#            = "#{current_visitor.name}."
#            - unless current_visitor.anonymous?
#              = link_to 'Preferences', preferences_user_path(current_visitor)
#              \/
#              = link_to 'Logout', logout_path
#            - else
#              = link_to 'Login', login_path
#              \/
#              = link_to 'Sign Up', pick_signup_path
#            - if @original_user.has_role?('admin', 'manager')
#              \/
#              = link_to 'Switch', switch_user_path(current_visitor)
  def login_line(options = {})
    opts = {
      :welcome  => "Welcome",
      :login => "Login",
      :signup => "Sign up",
      :logout => "Logout",
      :prefs => "Preferences",
      :guest => false,
      :name_method => "name"
    }
    opts.merge!(options)
    message = ""
    if current_visitor.anonymous?
      if opts[:guest]
        message += "#{opts[:welcome]} #{opts[:guest]} &nbsp;"
      end
      message += link_to opts[:login], login_path
      message += " / "
      message += link_to opts[:signup], 'javascript:Portal.openSignupModal();'
    else
      message += "#{opts[:welcome]} #{current_visitor.send(opts[:name_method])} &nbsp;"
      message += link_to opts[:prefs],  preferences_user_path(current_visitor)
      message += " / "
      message += link_to opts[:logout], logout_path
      if @original_user.has_role?('admin','manager')
        message += " "
        message += link_to 'Switch', switch_user_path(current_visitor)
      end
    end
    message
  end

  def settings_for(key)
    Admin::Settings.settings_for(key)
  end

  # this appears to not be used in master right now
  def current_user_can_author
    return true if current_visitor.has_role? "author"
    if settings_for(:teachers_can_author)
      return true unless current_visitor.portal_teacher.nil?
    end
    # TODO add aditional can-author conditions
    return false
  end

  # Rails 3.0 way of switching the format for a block of code
  # see: http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

  # This fixes an error in polymorphic_url brought on because the Admin::Settings model name is plural.
  def admin_settings_index_path(*args)
    admin_settings_path
  end

  def class_link_for_user
    if current_visitor.portal_teacher
      if current_visitor.has_active_classes?
        recent_activity_path
      else
        getting_started_path
      end
    elsif current_visitor.portal_student
      my_classes_path
    else
      root_path
    end
  end

  def current_user_home_path
    if current_user.nil?
      # anonymous home is the '/'
      root_path
    elsif BoolENV['RESEARCHER_REPORT_ONLY']
      learner_report_path
    elsif current_user.portal_student
      my_classes_path
    elsif APP_CONFIG[:recent_activity_on_login] && current_user.portal_teacher
      # Teachers are redirected to the "Recent Activity" page
      recent_activity_path
    else
      # this is a generic logged in user (not teacher or student)
      getting_started_path
    end
  end

  def maybe_redact_student_email(email)
    if email.start_with?("no-email-") && email.end_with?("@concord.org")
      "<auto-generated student email>"
    else
      email
    end
  end
end
