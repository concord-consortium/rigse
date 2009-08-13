include OtmlHelper
include JnlpHelper

module ApplicationHelper

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
  def dom_id_for(component, *optional_prefixes)
    optional_prefixes.flatten!
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.underscore
    class_name.gsub!('/', '_')
    id = component.id.nil? ? Time.now.to_i : component.id
    id_string = id.to_s
    "#{prefix}#{class_name}_#{id_string}"
  end

  def dom_class_for(component)
    component.class.name.underscore
  end

  def short_name(name)
    name.strip.downcase.gsub(/\W+/, '_')
  end

  def display_system_info
    list1 = 
      content_tag('ul', :class => 'tiny menu_h') do
        list = ''
        git_repo_info.collect { |info| list << content_tag('li') { info } }
        list << content_tag('li') { '|' }
        maven_jnlp_info.collect { |info| list << content_tag('li') { info } }
        list
      end
    # list2 = 
    #   content_tag('ul', :class => 'tiny menu_h') do
    #     list = ''
    #     maven_jnlp_info.collect { |info| list << content_tag('li') { info } }
    #     list
    #   end
    # "#{list1}\n<br />#{list2}"
  end

  def git_repo_info
    if repo = Grit::Repo.new(".")
      branch = repo.head.name
      last_commit = repo.commits(branch).first
      message = last_commit.message
      link = "<a title='#{message}' href='http://github.com/stepheneb/rigse/commit/#{last_commit.id}'>#{truncate(last_commit.id, :length => 16)}</a>"
      name = last_commit.author.name
      date = last_commit.authored_date.strftime('%a %b %d %H:%M:%S')
      short_message = truncate(last_commit.message, :length => 54)
      [branch, link, name, date, short_message]
    else
      []
    end
  end

  def maven_jnlp_info
    name = @jnlp_adaptor.jnlp.versioned_jnlp_url.maven_jnlp_family.name
    version = @jnlp_adaptor.jnlp.versioned_jnlp_url.version_str
    url = @jnlp_adaptor.jnlp.versioned_jnlp_url.url
    link = "<a href='#{url}'>#{version}</a>"
    info = [name, link]
    if @project.snapshot_enabled
      info << "(snapshot)"
    else
      info << "(frozen)"
    end
    
    # if @jnlp_adaptor.jnlp.versioned_jnlp_url.maven_jnlp_family.snapshot_version == version
    #   info << "(snapshot)"
    # else
    #   info << "(frozen)"
    # end
  end    

  def display_repo_info
    if repo = Grit::Repo.new(".")
      branch = repo.head.name
      last_commit = repo.commits(branch).first
      message = last_commit.message
      content_tag('ul', :class => 'tiny menu_h') do
        list = ''
        list << content_tag('li') { branch }
        list << content_tag('li') { "<a title='href='http://github.com/stepheneb/rigse/commit/#{last_commit.id}'>#{truncate(last_commit.id, :length => 16)}</a>" }
        list << content_tag('li') { last_commit.author.name }
        list << content_tag('li') { last_commit.authored_date.strftime('%a %b %d %H:%M:%S') }
        list << content_tag('li') { truncate(message, :length => 70) }
      end
    end
  end
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
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

  def pdf_footer(message)
    pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
      pdf.stroke_horizontal_rule
      pdf.pad(10) do
        pdf.text message, :size => 16
      end
    end
  end

  def render_show_partial_for(component,teacher_mode=false)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/show", :locals => { class_name.to_sym => component, :teacher_mode => teacher_mode}
  end

  def render_edit_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/remote_form", :locals => { class_name.to_sym => component }
  end

  def wrap_edit_link_around_content(component, options={})
    url      = options[:url]      || edit_url_for(component)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success]  || nil
    js_function = remote_function(:url => url, :update => update, :method => method, :complete => complete, :success => success)
    dom_id = dom_id_for(component, :edit_link)

    capture_haml do
      if component.changeable?(current_user)
        haml_tag :div, :id=> dom_id, :class => 'editable_block', :onDblClick=> js_function  do
          if block_given? 
            yield
          end
        end
      else
        if block_given? 
          yield
        end
      end
    end
  end

  def edit_button_for(component, options={}, scope=false)
    url      = options[:url]      || edit_url_for(component, scope)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success]  || nil
    remote_link_button "edit.png",  :url => url, :title => "edit #{component.class.display_name.downcase}", :update => update, :method => method, :complete => complete, :success => success
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
  
  def edit_menu_for(component, form, kwds={:omit_cancel => true}, scope=false)
    component = (component.respond_to? :embeddable) ? component.embeddable : component
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_tag(:h3,{:class => 'menu'}) do
            haml_concat title_for_component(component)
          end
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          haml_tag :ul, {:class => 'menu'} do
            if (component.changeable?(current_user))
              haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Save") }
              haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Cancel") } unless kwds[:omit_cancel]
            end
          end
        end
      end
    end
  end
  
  def accordion_for(model, title, dom_prefix='')
    capture_haml do
      haml_tag :div, :id => dom_id_for(model, dom_prefix), :class => 'accordion_container' do
        haml_tag :div, :class => 'accordion_name' do
          haml_concat title
        end
        haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_toggle}"), :class => 'accordion_toggle'
        haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_content}"), :class => 'accordion_content', :style=>'display: none;' do
          if block_given?
            yield
          end
        end
      end
    end
  end

  def otrunk_edit_button_for(component, options={})
    controller = component.class.name.pluralize.underscore
    id = component.id
    link_to image_tag("edit_otrunk.png"), { :controller => controller, :action => 'edit', :format => 'jnlp', :id => id }, :class => 'rollover' , :title => "edit #{component.class.display_name.downcase} using OTrunk"
  end

  def otml_url_for(component,options={})
    url = url_for( 
      :controller => component.class.name.pluralize.underscore, 
      :action => :show,
      :format => :otml, 
      :id  => component.id,
      :only_path => false,
      :teacher_mode => options[:teacher_mode] )
    URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
  end

  def edit_otml_url_for(component)
    url = url_for( 
      :controller => component.class.name.pluralize.underscore, 
      :action => :edit,
      :format => :otml, 
      :id  => component.id,
      :only_path => false )
    URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
  end

  def update_otml_url_for(component, escape=true)
    url = url_for( 
      :controller => component.class.name.pluralize.underscore, 
      :action => :update,
      :format => :otml, 
      :id  => component.id,
      :only_path => false )
    if escape
      URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
    else
      url
    end
  end

  def print_link_for(component)
     component_display_name = component.class.display_name.downcase
      name = component.name
      link_to("print #{component_display_name}", {
          :controller => component.class.name.pluralize.underscore, 
          :id  => component.id,
          :action => :show,
          :print => true
        },
        {
          :target => "#{component.name} printout",
          :title => "Open a new browser window with a a printable version of the #{component_display_name}: '#{name}'"
        })
  end
  
  def paste_link_for(acceptable_types,options={})
    clipboard_data_type  = options[:clipboard_data_type] || cookies[:clipboard_data_type]
    clipboard_data_id    = options[:clipboard_data_id]   || cookies[:clipboard_data_id]
    container_id         = options[:container_id] || params[:container_id]
    
    return "paste (nothing in clipboard)" unless clipboard_data_type
    
    if acceptable_types.include?(clipboard_data_type) 
      url = url_for :action => 'paste', :method=> 'post', :clipboard_data_type => clipboard_data_type, :clipboard_data_id => clipboard_data_id, :id =>container_id
      return link_to_remote("paste #{clipboard_data_type}:#{clipboard_data_id}", :url => url)
    end
    return "cant paste (#{clipboard_data_type}:#{clipboard_data_id}) here"
  end

  def run_link_for(component, as_name=nil,params={})
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_text = "preview #{component_display_name}"
    if as_name
      link_text << "as #{as_name}"
    end
    
    url = polymorphic_url(component, :format => :jnlp, :params => params)
    link_to(link_text, url, 
      :onclick => "show_alert($('launch_warning'),false);",
      :title => "Preview the #{component_display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.")
  end

  def otml_link_for(component, params={})
    link_to('otml', 
      :controller => component.class.name.pluralize.underscore, 
      :action => :show,
      :format => :otml, 
      :id  => component.id,
      :params => params)
  end

  def delete_button_for(model, options={})
    # find the page_element for the embeddable
    embeddable = (model.respond_to? :embeddable) ? model.embeddable : model
    controller = "#{model.class.name.pluralize.underscore}"
    if options[:redirect]
      url = url_for(:controller => controller, :action => 'destroy', :id=>model.id, :redirect=>options[:redirect])
    else
      url = url_for(:controller => controller, :action => 'destroy', :id=>model.id)
    end
    remote_link_button "delete.png", :confirm => "Delete  #{embeddable.class.display_name.downcase} named #{embeddable.name}?", :url => url, :method => :delete, :title => "delete #{embeddable.class.display_name.downcase}"
  end

  def link_to_container(container)
    link_to name_for_component(container), container, :class => 'container_link'
  end
  
  def title_for_component(component, options={})
    title = name_for_component(component, options)
    if RAILS_ENV == "development" || current_user.has_role?('admin')
      "<span class='component_title'>#{title}</span><span class='dev_note'> #{link_to(component.id, component)}</span>" 
    else
      "<span class='component_title'>#{title}</span>"
    end
  end
    
  def name_for_component(component, options={})
    name = ''
    unless options[:hide_componenent_name]
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
      when component.name == component.class.default_value('name') then ''
      when component.name then component.name
      else ''
    end    
  end

  def name_for_gse(gse)
    capture_haml do
      haml_tag(:ul, :class => 'menu_h') do
        haml_tag(:li) { haml_concat(link_to('GSE: ' + h(gse.gse_key),  grade_span_expectation_path(gse))) }
        haml_tag(:li) { haml_concat('Grade span: ' + h(gse.grade_span)) }
        haml_tag(:li) { haml_concat('Assessment target: ' + h(gse.assessment_target.number)) }
      end
    end
  end

  def show_menu_for(component, options={})
    is_page_element = (component.respond_to? :embeddable)
    deletable_element = component
    if is_page_element
      component = component.embeddable
    end
    view_class = teacher_only?(component) ? "teacher_only action_menu" : "action_menu"
    capture_haml do
      haml_tag :div, :class => view_class do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(component, options)
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          if is_page_element
            restrict_to 'admin' do
              haml_tag :div, :class => 'dropdown', :id => "actions_#{component.name}_menu" do
                haml_tag :ul do
                  haml_tag(:li) { haml_concat run_link_for(component) }
                  haml_tag(:li) { haml_concat print_link_for(component) }
                  haml_tag(:li) { haml_concat otml_link_for(component) }
                end
              end
              haml_concat(dropdown_button("actions.png", :name_postfix => component.name, :title => "actions for this page"))
            end
          end              
          if (component.changeable?(current_user))
            # haml_tag(:li, {:class => 'menu'}) { haml_concat toggle_more(component) }
            begin
              if component.authorable_in_java?
                haml_concat otrunk_edit_button_for(component, options)
              end
            rescue NoMethodError
            end
            haml_concat edit_button_for(component, options)
            haml_concat delete_button_for(deletable_element)  unless options[:omit_delete]
          end
        end
      end
    end
  end

  def toggle_link_title(future_state, current_state)
    "<span class='toggle'><span class='current_state'>#{current_state}</span><span class='future_state'>#{future_state}</span></span>"
  end

  def toggle_all(label='all', id_prefix='details_')
    link_to_function("show/hide #{label}", "$$('div[id^=#{id_prefix}]').each(function(d) { Effect.toggle(d,'blind', {duration:0.25}) });")
  end

  def toggle_more(component, details_id=nil, label="show/hide")
    toggle_id = dom_id_for(component,:show_hide)
    details_id ||= dom_id_for(component, :details)
   
    link_to_function(label, nil, :id => toggle_id, :class=>"small") do |page|
      page.visual_effect(:toggle_blind, details_id,:duration => 0.25)
      # page.replace_html(toggle_id,page.html(toggle_id) == more ? less : more)
    end
  end

  def dropdown_link_for(options ={})
    defaults = {
      :url        => "#",
      :text       => 'add content',
      :content_id => 'dropdown',
      :id         => 'add_content',
      :onmouseover => "dropdown_for('#{options[:id]||'dropdown'}','#{options[:content_id]||'add_content'}')"
    }
    options = defaults.merge(options)
    link_to(options[:text], options[:url], options)
  end

  def dropdown_button(image,options={})
    name = options[:name] || image.gsub(/\..*/,'') # remove extension of filename
    if options[:name_postfix]
      postfix = options[:name_postfix]
      content_id = "#{name}_#{postfix}_menu"
      id = "button_#{name}_#{postfix}_menu"
    else
      content_id = "#{name}_menu"
      id = "button_#{name}_menu"
    end
    defaults = {
      :name       =>  name,
      :text       =>  image_tag(image,:title => options[:title] || name),
      :class      => 'rollover',
      :content_id => content_id,
      :id         => id
    }
    options = defaults.merge(options)
    dropdown_link_for options
  end
  
  def link_button(image,url,options={})
    defaults = {
      :class      => 'rollover'
    }
    options = defaults.merge(options)
    link_to image_tag(image, :alt=>options[:title]),url,options
  end
  
  def remote_link_button(image,options={})
    defaults = {
      :html       => {
        :class => options[:class] || 'rollover',
        :id    => options[:id]
        },
      :title => options[:title] || 'no note here'
    }
    options = defaults.merge(options)
    link_to_remote image_tag(image, :alt=>options[:title],:title=>options[:title]),options
  end
  
  def function_link_button(image,javascript,options={})
    javascript ||= "alert('Hello world!'); return false;"
    defaults = {
      :class      => 'rollover'
    }
    options = defaults.merge(options)
    link_to_function(image_tag(image, :alt=>options[:title]), javascript, options)
  end
  
  def tab_for(component, options={})
    if(options[:active])
      "<li id=#{dom_id_for(component, :tab)} class='tab active'>#{link_to component.name, component, :class => 'active'}</li>"
    else
      "<li id=#{dom_id_for(component, :tab)} class='tab'>#{link_to component.name, component}</li>"
    end
  end
  
  def generate_javascript_datastore(data_collector)
    # 
    # data: [ [1,2.5], [2,3.7], [2.5,6.78] ]
    # 
    js = ''
    if data_collector.data_store_values
      if data_collector.data_store_values.length > 0
        js << "var default_data_#{data_collector.id} = #{data_collector.data_store_values.in_groups_of(2).inspect};\n"
      else
        js << "var default_data_#{data_collector.id} = [];\n"        
      end
    else
      js << "var default_data_#{data_collector.id} = [];\n"
    end
    js
  end
  
  # expects styles to contain space seperated list of style classes.
  def style_for_teachers(component,style_classes=[])
    if (teacher_only?(component))
      style_classes << 'teacher_only' # funny, just adding a style text
    end
    return style_classes
  end
  
  
  def style_for_item(component,style_classes=[]) 
    style_classes << 'item' << 'selectable' << 'item_selectable'
    if (component.respond_to? 'changeable?') && (component.changeable?(current_user))
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
  
  def in_render_scope?(thing)
    return true if thing == nil
    if @render_scope_additional_objects && @render_scope_additional_objects.include?(thing)
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
      @render_scope_additional_objects ||= []
      @render_scope_additional_objects << thing
      render_show_partial_for(thing)
    end
  end
  
  #
  # is a component viewable only by teacher?
  # cascading logic.
  # TODO: generic container-based method-forwarding mechanism
  #
  def teacher_only?(thing)
    if (thing.respond_to?("teacher_only?") && thing.teacher_only?)
      return true;
    end
    if (thing.respond_to?("parent"))
      while (thing = thing.parent)
        if (thing.respond_to?("teacher_only?"))
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
      render :partial => "home/project_info"
      @rendered_project_info = true
    end
  end
  
  def add_top_menu_item(link)
    @top_menu_items ||= []
    @top_menu_items << link
  end

  def htmlize_teacher_note_body(teacher_note)
    if teacher_note.body
      teacher_note.body.gsub(/\n/,"<br/>")
    else
      "<br/>"
    end
  end
  
  def runnable_list(options)
    grade_span = options[:grade_span] || ""
    domain_id = options[:domain_id].to_i
    name = options[:name]
    if domain_id > 0
      investigations = Investigation.published.like(name).with_gse.grade(grade_span).domain(domain_id)
    else
      investigations = Investigation.published.like(name).with_gse.grade(grade_span)
    end
    portal_clazz = options[:portal_clazz] || options[:portal_clazz_id] ? Portal::Clazz.find(options[:portal_clazz_id]) : nil
    if portal_clazz
      investigations = investigations - portal_clazz.offerings.map { |o| o.runnable }
    end
    investigations
  end
  
end
