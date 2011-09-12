include OtmlHelper
include JnlpHelper
include Clipboard

module ApplicationHelper
  def current_project
    @_project ||= Admin::Project.default_project
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
    if component.is_a?(ActiveRecord::Base)
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

  def display_system_info
    commit = git_repo_info
    jnlp = maven_jnlp_info
    info = <<-HEREDOC
<ul class="tiny menu_h">
  <li>#{commit[:branch]}</li>
  <li><a href="#{commit[:href]}">#{commit[:short_id]}</a></li>
  <li>#{commit[:author]}</li>
  <li>#{commit[:date]}</li>
  <li>#{commit[:short_message]}</li>
  <li>|</li>
  <li>#{jnlp[:name]}</li>
  <li><a href="#{jnlp[:href]}">#{jnlp[:version]}</a></li>
  <li>#{jnlp[:snapshot]}</li>
</ul>
    HEREDOC
  end

  def git_repo_info
    # For some strange reason running repo.head during tests sometimes generates this
    # error running the first time: Errno::ECHILD Exception: No child processes
    #
    # The operation seems to work fine the second time ... ?
    # Here's an example from the debugger:
    #
    #   (rdb:1) repo.head
    #   Errno::ECHILD Exception: No child processes
    #   (rdb:1) repo.head
    #   #<Grit::Head "emb-test">
    #
    repo = Grit::Repo.new(".")
    head = nil
    begin
      head = repo.head
    rescue Errno::ECHILD
      begin
        head = repo.head
      rescue Errno::ECHILD
      end
    end
    if head
      branch = head.name
      last_commit = repo.commits(branch).first
      {
        :branch => branch,
        :last_commit => repo.commits(branch).first,
        :short_message => truncate(last_commit.message, :length => 54),
        :href => "http://github.com/concord-consortium/rigse/commit/#{last_commit.id}",
        :short_id => truncate(last_commit.id, :length => 16),
        :name => last_commit.author.name,
        :date => last_commit.authored_date.strftime('%a %b %d %H:%M:%S')
      }
    else
      {}
    end
  end

  def maven_jnlp_info
    if current_project.maven_jnlp_family
      {
        :name => jnlp_adaptor.jnlp.versioned_jnlp_url.maven_jnlp_family.name,
        :version => jnlp_adaptor.jnlp.versioned_jnlp_url.version_str,
        :href => jnlp_adaptor.jnlp.versioned_jnlp_url.url,
        :snapshot => current_project.snapshot_enabled ? "(snapshot)" : "(frozen)"
      }
    else
      {
        :name => 'unknown',
        :version => 'unknown',
        :href => 'unknown',
        :snapshot => current_project.snapshot_enabled ? "(snapshot)" : "(frozen)"
      }
    end
  end

  def display_repo_info
    if repo = Grit::Repo.new(".")
      branch = repo.head.name
      last_commit = repo.commits(branch).first
      message = last_commit.message
      content_tag('ul', :class => 'tiny menu_h') do
        list = ''
        list << content_tag('li') { branch }
        list << content_tag('li') { "<a title='href='http://github.com/concord-consortium/rigse/commit/#{last_commit.id}'>#{truncate(last_commit.id, :length => 16)}</a>" }
        list << content_tag('li') { last_commit.author.name }
        list << content_tag('li') { last_commit.authored_date.strftime('%a %b %d %H:%M:%S') }
        list << content_tag('li') { truncate(message, :length => 70) }
      end
    end
  end

  def short_format_gse_summary(gse)
    gse.print_summary_data("<div><strong>%s</strong><ul>%s</ul></div>","<li>%s</li>")
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

  def pdf_footer(message)
    pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
      pdf.stroke_horizontal_rule
      pdf.pad(10) do
        pdf.text message, :size => 16
      end
    end
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
      :partial      => 'show'
    }
    opts.merge!(_opts)
    teacher_mode = opts[:teacher_mode]
    substitute = opts[:substitute]
    partial = "#{class_name.pluralize}/#{opts[:partial]}"
    render :partial => partial, :locals => { demodulized_class_name.to_sym => (substitute ? substitute : component), :teacher_mode => teacher_mode}
  end

  def render_show_partial_for(component,teacher_mode=false,substitute=nil)
    render_partial_for(component, {:teacher_mode => teacher_mode, :substitute => substitute})
  end

  def render_edit_partial_for(component,opts={})
    render_partial_for(component, {:partial => "remote_form"}.merge!(opts))
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
    title    = options[:title]    || "edit #{component.class.display_name.downcase}"
    remote_link_button "edit.png",  :url => url, :title => title, :update => update, :method => method, :complete => complete, :success => success
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
            #if (component.changeable?(current_user))
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

  def sort_dropdown(selected)
    sort_options = [ [ "Newest", "created_at DESC" ], [ "Alphabetical", "name ASC" ], [ "Popularity", "offerings_count DESC" ] ]
    select nil, :sort_order, sort_options, {:selected => selected, :include_blank => true }
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

  def report_link_for(reportable, action='report', link_text='Report ', title=nil)
    reportable_display_name = reportable.class.display_name.downcase
    action_string = action.gsub('_', ' ')
    name = reportable.name
    url = polymorphic_url(reportable, :action => action)
    if title.nil?
      title = "Display a #{action_string} for the #{reportable_display_name}: '#{name}' in a new browser window."
    end
    link_to(link_text, url, :popup => true, :title => title)
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
    #url = duplicate_investigation_url(component)
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
    link_to(link_text,url,:popup => true)
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
    if model.changeable? current_user
      # find the page_element for the embeddable
      embeddable = (model.respond_to? :embeddable) ? model.embeddable : model
      controller = "#{model.class.name.pluralize.underscore}"
      if defined? model.parent
        options[:redirect] ||= url_for model.parent
      end
      if options[:redirect]
        url = url_for(:controller => controller, :action => 'destroy', :id=>model.id, :redirect=>options[:redirect])
      else
        url = url_for(:controller => controller, :action => 'destroy', :id=>model.id)
      end
      remote_link_button "delete.png", :confirm => "Delete  #{embeddable.class.display_name.downcase} named #{embeddable.name}?", :url => url, :title => "delete #{embeddable.class.display_name.downcase}"
    end
  end

  def link_to_container(container, options={})
    link_to name_for_component(container, options), container, :class => 'container_link'
  end

  def title_for_component(component, options={})
    title = name_for_component(component, options)
    id = dom_id_for(component, options[:id_prefix], :title)
    if ::Rails.env == "development" || current_user.has_role?('admin')
      "<span id=#{id} class='component_title'>#{title}</span><span class='dev_note'> #{link_to(component.id, component)}</span>"
    else
      "<span id=#{id} class='component_title'>#{title}</span>"
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

  def name_for_gse(gse)
    capture_haml do
      haml_tag(:ul, :class => 'menu_h') do
        haml_tag(:li) { haml_concat(link_to('GSE: ' + h(gse.gse_key),  grade_span_expectation_path(gse))) }
        haml_tag(:li) { haml_concat('Grade span: ' + h(gse.grade_span)) }
        haml_tag(:li) { haml_concat('Assessment target: ' + h(gse.assessment_target.number)) }
      end
    end
  end

  def open_response_learner_stat(learner)
    reportUtil = Report::Util.factory(learner.offering)
    answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::OpenResponse).size
    total = reportUtil.embeddables(:type => Embeddable::OpenRespose).size
    " Open Response: #{answered}/#{total} "
  end

  def multiple_choice_learner_stat(learner)
    reportUtil = Report::Util.factory(learner.offering)
    answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    total = reportUtil.embeddables(:type => Embeddable::MultipleChoice).size
    " Multiple Choice: #{answered}/#{correct}/#{total} "
  end

  def sessions_learner_stat(learner)
    sessions = learner.bundle_logger.bundle_contents.count
    if sessions > 0
      pluralize(learner.bundle_logger.bundle_contents.count, 'session')
    else
      ''
    end
  end

  def learner_specific_stats(learner)
    reportUtil = Report::Util.factory(learner.offering)
    or_answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::OpenResponse).size
    or_total = reportUtil.embeddables(:type => Embeddable::OpenResponse).size
    mc_answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    mc_correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    mc_total = reportUtil.embeddables(:type => Embeddable::MultipleChoice).size
    "sessions: #{learner.bundle_logger.bundle_contents.count}, open response: #{or_answered}/#{or_total}, multiple choice:  #{mc_answered}/#{mc_correct}/#{mc_total}"
  end

  def report_details_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true, :type => :open_responses, :correctable => false }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(learner, options)
          haml_concat learner_specific_stats(learner)
        end
      end
    end
  end

  def report_correct_count_for_learner(learner, opts = {} )
    options = {:type => Embeddable::MultipleChoice}
    options.update(opts)
    reportUtil = Report::Util.factory(learner.offering)
    mc_correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => options[:type]).size
  end

  def learner_report_summary(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true, :hide_statistics => true, :show_selection_controls => true }
    options.update(opts)
    unless options[:hide_statistics]
      reportUtil = Report::Util.factory(learner.offering)
      questions = reportUtil.embeddables
      answered  = reportUtil.saveables(:learner => learner, :answered => true)
    end
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(learner.offering, options)
          if options[:show_selection_controls]
            haml_concat selectAllNone(dom_id_for(learner.offering, :details))
          end
        end
      end
      unless options[:hide_statistics]
        haml_tag :div do
          haml_tag :p do
            haml_concat("#{questions.size} questions, #{answered.size} have been answered")
          end
        end
      end
    end
  end

  def offering_report_summary(offering, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true, :hide_statistics => true, :show_selection_controls => true }
    options.update(opts)
    unless options[:hide_statistics]
      reportUtil = Report::Util.factory(offering)
      questions = reportUtil.embeddables(:type => options[:type])
      type_id_lambda = lambda{|s|
        types = Investigation.reportable_types.map{|t| t.to_s.demodulize.underscore }
        type = types.detect{|t| s.respond_to?(t) }
        if type
          type_id = "#{type}_id"
          embeddable_identifier = "#{type}-#{s.send(type_id)}"
        else
          nil
        end
      }
      answered = reportUtil.saveables_by_embeddable
      answered = answered.select{|s,v| s.kind_of? options[:type]} if options[:type]
    end
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(offering, options)
          if options[:show_selection_controls]
            haml_concat selectAllNone(dom_id_for(offering, :details))
          end
        end
      end
      unless options[:hide_statistics]
        haml_tag :div do
          haml_tag :p do
            haml_concat("#{questions.size} questions, #{answered.size} have been answered")
          end
        end
      end
    end
  end

  def offering_details_open_response(offering, open_response, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    reportUtil = Report::Util.factory(offering)
    total = reportUtil.learners.size
    answered = reportUtil.saveables(:embeddable => open_response, :answered => true).size
    skipped = total - answered
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left'
      end
      haml_tag(:div, :class => 'item', :style => 'width: 565px; display: -moz-inline-block; display: inline-block;') {
        haml_concat(open_response.prompt)
      }
      haml_tag(:div, :style => 'width: 90px; display: -moz-inline-block; display: inline-block; text-align: right; vertical-align: top; font-weight: bold;') {
        haml_tag(:div) { haml_concat("Answered") }
        haml_tag(:div) { haml_concat("Skipped") }
        haml_tag(:div) { haml_concat("Total") }
      }
      haml_tag(:div, :style => 'width: 15px; display: -moz-inline-block; display: inline-block; text-align: right; vertical-align: top;') {
        haml_tag(:div) { haml_concat(answered) }
        haml_tag(:div) { haml_concat(skipped) }
        haml_tag(:div) { haml_concat(total) }
      }
    end
  end

  def offering_details_image_question(offering, image_question, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    reportUtil = Report::Util.factory(offering)
    total = reportUtil.learners.size
    answered_saveables = reportUtil.saveables(:embeddable => image_question, :answered => true)
    answered = answered_saveables.size
    skipped = total - answered
    answers_map = answered_saveables.sort_by{|s| [s.learner.last_name, s.learner.first_name]}.map{|sa| {:name => sa.learner.name, :image_url => dataservice_blob_raw_url(:id => sa.answer.id, :token => sa.answer.token)} }
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left'
      end
      haml_tag(:div, :class => 'item', :style => 'width: 565px; display: -moz-inline-block; display: inline-block;') {
        haml_concat(image_question.prompt)
      }
      haml_tag(:div, :style => 'width: 90px; display: -moz-inline-block; display: inline-block; text-align: right; vertical-align: top; font-weight: bold;') {
        haml_tag(:div) { haml_concat("Answered") }
        haml_tag(:div) { haml_concat("Skipped") }
        haml_tag(:div) { haml_concat("Total") }
      }
      haml_tag(:div, :style => 'width: 15px; display: -moz-inline-block; display: inline-block; text-align: right; vertical-align: top;') {
        haml_tag(:div) { haml_concat(answered) }
        haml_tag(:div) { haml_concat(skipped) }
        haml_tag(:div) { haml_concat(total) }
      }
      haml_tag(:div, :style => 'width: 670px') {
        haml_concat(contentflow("image_question_#{image_question.id}_content_flow") do
          capture_haml do
            answers_map.each do |b|
              haml_tag(:div, :class => 'item') {
                haml_tag(:img, :class =>' content', :src=> b[:image_url], :title => b[:name])
                haml_tag(:div, :class => 'caption') {
                  haml_concat(b[:name])
                }
              }
            end
          end
        end
        )
      }
    end
  end

  def offering_details_multiple_choice(offering, multiple_choice, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    answer_counts = {}
    reportUtil = Report::Util.factory(offering)
    learners = reportUtil.learners
    learners.each do |learner|
      saveable = reportUtil.saveable(learner, multiple_choice)
      answer = saveable.answer
      answer_counts[answer] ||= 0
      answer_counts[answer] += 1
    end
    not_answered_count = answer_counts.has_key?("not answered") ? answer_counts["not answered"].to_i : 0
    all_choices = multiple_choice.choices
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left'
      end
      haml_tag(:div) {
        haml_tag(:div, :class => 'item') {
          haml_concat(multiple_choice.prompt)
        }
        haml_tag(:div) {
          haml_tag(:div, :class => 'table') {
            haml_tag(:div, :class => 'row', :style => 'display: none;') {
              haml_tag(:div, :class => "cell cellheader") { haml_concat("Option")}
              haml_tag(:div, :class => "cell cellheader") { haml_concat("Graph")}
              haml_tag(:div, :class => "cell cellheader") { haml_concat("Percent")}
              haml_tag(:div, :class => "cell cellheader") { haml_concat("Count")}
            }
            all_choices.each_with_index do |choice,i|
              answer_count = answer_counts.has_key?(choice.choice) ? answer_counts[choice.choice] : 0
              correctness = choice.is_correct ? "correct" : "incorrect"
              haml_tag(:div, :class => 'row') {
                haml_tag(:div, :class => "cell optionlabel #{correctness}") {
                  haml_concat("#{i+1}. #{choice.choice}")
                }
                haml_tag(:div, :class => 'cell optionbar') {
                  haml_tag(:div, :class => "optionbarbar #{correctness}", :id => "question_id_#{multiple_choice.id}_bar_graph_choice_#{choice.id}", :style => "width: #{percent(answer_count, learners.size)}%;") {
                    haml_concat("&nbsp;")
                  }
                }
                haml_tag(:div, :class => 'cell optionpercent') {
                  haml_concat(percent_str(answer_count, learners.size))
                }
                haml_tag(:div, :class => 'cell optioncount') {
                  haml_concat(answer_count)
                }
              }
            end
            haml_tag(:div, :class => 'row') {
              haml_tag(:div, :class => 'cell optionlabel') {
                haml_concat("Not answered")
              }
              haml_tag(:div, :class => 'cell optionbar') {
                haml_tag(:div, :class => 'optionbarbar not_answered', :id => "question_id_#{multiple_choice.id}_bar_graph_choice_no_answer", :style => "width: #{percent(not_answered_count, learners.size)}%;") {
                  haml_concat("&nbsp;")
                }
              }
              haml_tag(:div, :class => 'cell optionpercent') {
                haml_concat(percent_str(not_answered_count, learners.size))
              }
              haml_tag(:div, :class => 'cell optioncount') {
                haml_concat("#{not_answered_count}")
              }
            }
            haml_tag(:div, :class => 'row', :style => 'border-top: 2px solid black;') {
              haml_tag(:div, :class => 'cell optionlabel') {
                haml_concat("&nbsp;")
              }
              haml_tag(:div, :class => 'cell optionbar', :style => 'font-weight: bold; text-align: right; padding-right: 5px;') {
                haml_concat("Totals:")
              }
              haml_tag(:div, :class => 'cell optionpercent') {
                haml_concat(percent_str(1, 1))
              }
              haml_tag(:div, :class => 'cell optioncount') {
                haml_concat("#{learners.size}")
              }
            }
          }
        }
      }
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

  def saveable_for_learner(question, learner)
    reportUtil = Report::Util.factory(learner.offering)
    reportUtil.saveable(learner, question)
  end

  def menu_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_activity_options' do
          if learner.offering.runnable.run_format == :jnlp
            haml_concat link_to('Run', run_url_for(learner))
            haml_concat " | "
            if current_user.has_role?("admin")
              haml_concat report_link_for(learner, 'bundle_report', 'Bundles ')
              haml_concat " | "
            end
          end
          haml_concat report_link_for(learner, 'report', 'Report')
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

  def menu_for_offering(offering, opts = {})
    options = {
      :omit_delete => true,
      :omit_edit => true,
      :hide_component_name => true,
      :print_link =>dropdown_link_for(:text => "Print", :id=> dom_id_for(offering.runnable,"print_rollover"), :content_id=> dom_id_for(offering.runnable,"print_dropdown"),:title => "print this #{top_level_container_name}")
    }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu_activity' do
        haml_tag :div, :class => 'action_menu_activity_options' do
          haml_concat options[:print_link]
          haml_concat " | "
          haml_concat dropdown_link_for(:text => "Run", :id=> dom_id_for(offering.runnable,"run_rollover"), :content_id=> dom_id_for(offering.runnable,"run_dropdown"),:title =>"run this #{top_level_container_name}")
          haml_concat " | "
          haml_concat report_link_for(offering, 'report', 'Report')
          haml_concat " | "

          if offering.active?
            haml_concat activation_toggle_link_for(offering, 'deactivate', 'Deactivate')
          else
            haml_concat activation_toggle_link_for(offering, 'activate', 'Activate')
          end

          # haml_concat " | "
          # haml_concat report_link_for(offering, 'open_response_report','OR Report')
          # haml_concat " | "
          # haml_concat report_link_for(offering, 'multiple_choice_report','MC Report')
        end
        haml_tag :div, :class => 'action_menu_activity_title' do
          haml_concat title_for_component(offering, options)
          # haml_concat "Active students: #{offering.learners.length}"
        end
      end
    end
  end

  def menu_for_school(school, options = { :omit_delete => true, :omit_edit => true, :hide_componenent_name => true })
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(school, options)
          haml_concat "active classes: #{school.clazzes.active.length}"
        end
      end
    end
  end

  def show_menu_for(component, options={})
    is_page_element = (component.respond_to? :embeddable)
    deletable_element = component
    if is_page_element
      component = component.embeddable
    end
    view_class = for_teacher_only?(component) ? "teacher_only action_menu" : "action_menu"
    capture_haml do
      haml_tag :div, :class => view_class do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(component, options)
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          if (component.changeable?(current_user))
            begin
              if component.authorable_in_java?
                haml_concat otrunk_edit_button_for(component, options)
              end
            rescue NoMethodError
            end
            haml_concat edit_button_for(component, options)  unless options[:omit_edit]
            haml_concat delete_button_for(deletable_element) unless options[:omit_delete]
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
    link_to(options[:text], options[:url], options.except(:text, :url))
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
    link_to image_tag(image, :alt=>options[:title]) , url, options
  end

  def remote_link_button(image,options={})
    defaults = {
      :html       => {
        :class => options[:class] || 'rollover',
        :id    => options[:id],
        :title => options[:title] || 'no note here'
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
    if (for_teacher_only?(component))
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
    Investigation.search_list(options)
  end

  def students_in_class(all_students)
    all_students.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

#            Welcome
#            = "#{current_user.name}."
#            - unless current_user.anonymous?
#              = link_to 'Preferences', preferences_user_path(current_user)
#              \/
#              = link_to 'Logout', logout_path
#            - else
#              = link_to 'Login', login_path
#              \/
#              = link_to 'Sign Up', pick_signup_path
#            - if @original_user.has_role?('admin', 'manager')
#              \/
#              = link_to 'Switch', switch_user_path(current_user)
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
    if current_user.anonymous?
      if opts[:guest]
        message += "#{opts[:welcome]} #{opts[:guest]} &nbsp;"
      end
      message += link_to opts[:login], login_path
      message += " / "
      message += link_to opts[:signup], pick_signup_path
    else
      message += "#{opts[:welcome]} #{current_user.send(opts[:name_method])} &nbsp;"
      message += link_to opts[:prefs],  preferences_user_path(current_user)
      message += " / "
      message += link_to opts[:logout], logout_path
      if @original_user.has_role?('admin','manager')
        message += " "
        message += link_to 'Switch', switch_user_path(current_user)
      end
    end
    message
  end

  def selectAllNone(parentId)
    capture_haml do
      haml_tag :span, :class => 'filter_selection_control' do
        haml_concat " ("
        haml_tag :a, "all", :onClick => "selectAll('##{parentId}'); return false;", :href => '#'
        haml_concat " | "
        haml_tag :a, "none", :onClick => "selectNone('##{parentId}'); return false;", :href => '#'
        haml_concat " )"
      end
    end
  end

  def use_contentflow
    javascript_include_tag("contentflow/contentflow.js").sub(/></, " load='white' ><")
  end

  def contentflow(name, opts = {})
    defaults = {:load_indicator => false, :scrollbar => true}
    opts.merge!(defaults){|k,o,n| o}

    capture_haml do
      haml_concat javascript_tag "var myNewFlow = new ContentFlow('#{name}', { reflectionHeight: 0, circularFlow: false, startItem: 'first' } );"
      haml_tag :div, :class => 'ContentFlow', :id => name do
        if opts[:load_indicator]
          haml_tag :div, :class => 'loadIndicator' do
            haml_tag :div, :class => 'indicator'
          end
        end
        haml_tag :div, :class => 'flow' do
          if block_given?
            haml_concat yield
          end
        end
        haml_tag :div, :class => 'globalCaption' do
          haml_concat opts[:global_caption]
        end
        if opts[:scrollbar]
          haml_tag :div, :class => 'scrollbar' do
            haml_tag :div, :class => 'slider' do
              haml_tag :div, :class => 'position'
            end
          end
        end
      end
    end
  end
  
  def settings_for(key)
    Admin::Project.settings_for(key)
  end

  # this appears to not be used in master right now
  def current_user_can_author
    return true if current_user.has_role? "author" 
    if settings_for(:teachers_can_author)
      return true unless current_user.portal_teacher.nil?
    end
    # TODO add aditional can-author conditions
    return false
  end

end
