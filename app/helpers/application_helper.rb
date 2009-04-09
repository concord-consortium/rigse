module ApplicationHelper

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

  def render_content_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/#{class_name}", :locals => { class_name.to_sym => component }
  end

  def render_edit_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/remote_form", :locals => { class_name.to_sym => component }
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
  def dom_id_for(component, *optional_prefixes)
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.underscore
    id_string = component.id.to_s
    "#{prefix}#{class_name}_#{id_string}"
  end

  def dom_class_for(component)
    component.class.name.underscore
  end

  def edit_button_for(component, options={})
    url      = options[:url]      || edit_url_for(component)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success] || nil
    link_to_remote('edit', :url => url, :update => update, :method => method, :complete => complete, :success => success)
  end

  def delete_button_for_page_component(page, component)
    page_element = page.element_for(component)
    link_to_remote('delete',  
      :confirm => "Delete #{component.class.human_name} named #{component.name}?", 
      :html => {:class => 'delete'}, 
      :url => { 
        :action => 'delete_element', 
        :dom_id => dom_id_for(page_element), 
        :element_id => page_element.id }
      )
  end

  def delete_button_for(model)
    link_to('delete',  
      :confirm => "Delete  #{model.class.human_name} named #{model.name}?", 
      :html => {:class => 'delete'}, 
      :url => { :action => '' })
  end

  def edit_url_for(component)
    { :controller => component.class.name.pluralize.underscore, 
      :action => :edit, 
      :id  => component.id }
  end

  def name_for_component(component)
    if RAILS_ENV == "development"
      "#{component.id}: #{component.name}" 
    else
      "#{component.name}"
    end
  end

  def edit_menu_for(component, form)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_tag :ul, :class => 'sections sortable' do
            haml_tag :li, {:class => 'menu'} do
              haml_concat name_for_component(component)
            end
          end
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          haml_tag :ul do
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Save") }
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Cancel") }
          end
        end
      end
    end
  end

  def show_menu_for(component, options={})
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_tag :ul, :class => 'sections sortable' do
            haml_tag :li, {:class => 'menu'} do
              haml_concat name_for_component(component)
            end
          end
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          haml_tag :ul do
            haml_tag(:li, {:class => 'menu'}) { haml_concat toggle_more(component) }
            haml_tag(:li, {:class => 'menu'}) { haml_concat edit_button_for(component, options) }
          end
        end
      end
    end
  end

  def toggle_link_title(future_state, current_state)
    "<span class='toggle'><span class='current_state'>#{current_state}</span> &raquo; <span class='future_state'>#{future_state}</span></span>"
  end

  def toggle_more(component, details_id=nil, label="show/hide")
    toggle_id = dom_id_for(component,:show_hide)
    details_id ||= dom_id_for(component, :details)
   
    link_to_function(label, nil, :id => toggle_id, :class=>"small") do |page|
      page.visual_effect(:toggle_blind, details_id,:duration => 0.25)
      # page.replace_html(toggle_id,page.html(toggle_id) == more ? less : more)
    end
  end

end
