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
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.underscore
    id = component.id.nil? ? Time.now.to_i : component.id
    id_string = id.to_s
    "#{prefix}#{class_name}_#{id_string}"
  end

  def dom_class_for(component)
    component.class.name.underscore
  end


  def display_repo_info
    if repo = Grit::Repo.new(".")
      last_commit = repo.commits.first
      content_tag('ul', :class => 'tiny') do
        list = ''
        list << content_tag('li') { "commit: #{truncate(last_commit.id, :length => 16)}" }
        list << content_tag('li') { "author: #{last_commit.author.name}" }
        list << content_tag('li') { "date: #{last_commit.authored_date.strftime('%a %b %d %H:%M:%S')}" }
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


  def render_show_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/show", :locals => { class_name.to_sym => component }
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

  def edit_button_for(component, options={})
    url      = options[:url]      || edit_url_for(component)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success]  || nil
    remote_link_button "edit.png",  :url => url, :title => "edit #{component.class.display_name.downcase}", :update => update, :method => method, :complete => complete, :success => success
  end
  
  def otml_url_for(component)
    url = url_for( 
      :controller => component.class.name.pluralize.underscore, 
      :action => :show,
      :format => :otml, 
      :id  => component.id,
      :only_path => false )
    URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
  end
  
  def print_link_for(component)
     component_display_name = component.class.display_name.downcase
      name = component.name
      link_to("print #{component_display_name}", {
          :controller => component.class.name.pluralize.underscore, 
          :action => :print, 
          :id  => component.id
        },
        {
          :target => "#{component.name} printout",
          :title => "Open a new browser window with a a printable version of the #{component_display_name}: '#{name}'"
        })
  end
  
  def run_link_for(component, prefix='')
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_to("#{prefix}run #{component_display_name}", {
        :controller => component.class.name.pluralize.underscore, 
        :action => :show,
        :format => :jnlp, 
        :id  => component.id
      },
      :title => "Start the #{component_display_name}: '#{name}' as a Java Web Start application. The first time you do this it may take a while to startup as the Java code is downloaded and saved on your hard drive.")
  end

  def otml_link_for(component)
    link_to('otml', 
      :controller => component.class.name.pluralize.underscore, 
      :action => :show,
      :format => :otml, 
      :id  => component.id)
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
    remote_link_button "delete.png", :confirm => "Delete  #{embeddable.class.display_name.downcase} named #{embeddable.name}?", :url => url, :title => "delete #{embeddable.class.display_name.downcase}"
  end

  def edit_url_for(component)
    { :controller => component.class.name.pluralize.underscore, 
      :action => :edit, 
      :id  => component.id }
  end

  def name_for_component(component)
    if component.id.nil?
      return "new #{component.class.name.humanize}"
    end
    if RAILS_ENV == "development" || current_user.has_role?('admin')
      return "<span class='component_title'>#{component.name}</span><span class='dev_note'> #{component.id}</span>" 
    else
      return "<span class='component_title'>#{component.name}</span>"
    end
  end

  def edit_menu_for(component, form, kwds={:omit_cancel => true})
    component = (component.respond_to? :embeddable) ? component.embeddable : component
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          
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

  def show_menu_for(component, options={})
    embeddable = (component.respond_to? :embeddable) ? component.embeddable : component
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat link_to name_for_component(embeddable), embeddable
        end
        haml_tag :div, :class => 'action_menu_header_right' do
            restrict_to 'admin' do
              haml_tag :div, :class => 'dropdown', :id => "actions_#{embeddable.name}_menu" do
              haml_tag :ul do
              haml_tag(:li) { haml_concat run_link_for(embeddable) }
              haml_tag(:li) { haml_concat print_link_for(embeddable) }
              haml_tag(:li) { haml_concat otml_link_for(embeddable) }
              end
              end
              haml_concat dropdown_button "actions.png", :name_postfix => embeddable.name, :title => "actions for this page"
              
            if (component.changeable?(current_user))
              # haml_tag(:li, {:class => 'menu'}) { haml_concat toggle_more(component) }
              haml_concat edit_button_for(embeddable, options)
              haml_concat delete_button_for(component)
            end
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
    return link_to options[:text], options[:url], options
  end

  def dropdown_button(image,options={})
    name = image.gsub(/\..*/,'') # remove extension of filename
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
      :text       =>  image_tag(image,:title => name),
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
  
  def simple_div_helper_that_yields
    capture_haml do
      haml_tag :div, :class => 'simple_div' do
        if block_given? 
          haml_concat yield
        end
      end
    end
  end
  
end
