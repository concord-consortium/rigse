module ApplicationHelper
  
  
  def display_repo_info
    if repo = Grit::Repo.new(".")
      last_commit = repo.commits.first
      content_tag('ul') do
        list = ''
        list << content_tag('li') { "commit: #{last_commit.id}" }
        list << content_tag('li') { "author: #{last_commit.author.name}" }
        list << content_tag('li') { "date: #{last_commit.authored_date}" }
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
  
  def partial_for(component)
      # dynamically find the partial for the 
      class_name = component.class.name.underscore
      # return "#{class_name.pluralize}/sortable_#{class_name}"
      "#{class_name.pluralize}/#{class_name}"
  end
  
  def render_partial_for(component)
    class_name = component.class.name.underscore
    render :partial => "#{class_name.pluralize}/#{class_name}", :locals => { class_name.to_sym => component }
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
  
  def edit_button_for_component(component, options={})
    url      = options[:url]      || edit_url_for_component(component)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    button_to_remote('edit', :url => url, :update => update, :method => method, :complete => complete)
  end
  
  def delete_button_for_page_component(page, component)
    button_to_remote('delete',  
      :confirm => "Delete #{component.class.human_name} named #{component.name}?", 
      :html => {:class => 'delete'}, 
      :url => { 
        :action => 'delete_element', 
        :dom_id => dom_id_for(page.element_for(component)), 
        :element_id => page.element_for(component).id }
      )
  end
  
  def edit_url_for_component(component)
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
  
  def edit_menu_for_component(component, form)
    content_tag('div', :class => 'menu') do
      content_tag('ul') do
        list = ''
        list << content_tag('li') { name_for_component(component) }
        list << content_tag('li') { form.submit "Save" }
        list << content_tag('li') { form.submit "Cancel" }
        # list << content_tag('li') { yield dom_id_for(component, :delete, :item) }
      end
    end
  end

  def show_menu_for_component(component, options={})
    content_tag('div', :class => 'menu') do
      content_tag('ul') do
        list = ''
        list << content_tag('li') { name_for_component(component) }
        list << content_tag('li') { edit_button_for_component(component, options) }
        # list << content_tag('li') { yield dom_id_for(component, :delete, :item) }
      end
    end
  end
     


end
