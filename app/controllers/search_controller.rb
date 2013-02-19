class SearchController < ApplicationController
  
  before_filter :teacher_only, :only => [:index, :show]
  
  protected
  
  def teacher_only
    if current_visitor.portal_student
      redirect_to(:root)
    end
  end
  
  in_place_edit_for :investigation, :search_term
  
  public
  def search_material
    search_options=get_searchoptions()
    @investigations_count=0
    @activities_count=0
    @external_activities_count=0
    if @material_type.include?('investigation')
      @investigations = Investigation.search_list(search_options)
      @investigations_count = @investigations.length
      @investigations = @investigations.paginate(:page => @investigation_page, :per_page => 10) 
    end
    if @material_type.include?('activity')
      @activities = Activity.search_list(search_options)
      @activities_count = @activities.length
      @activities = @activities.paginate(:page => @activity_page, :per_page => 10)
    end
    if @material_type.include?('external_activity')
      @external_activities = ExternalActivity.search_list(search_options)
      @external_activities_count = @external_activities.length
      @external_activities = @external_activities.paginate(:page => @external_activity_page, :per_page => 10)
    end
  end
  
  def index
    search_material();
  end
  
  def show
    search_material();
    if request.xhr?
      render :update do |page| 
        page.replace_html 'offering_list', :partial => 'search/search_results',:locals=>{:investigations=>@investigations,:activities=>@activities,:external_activities=>@external_activities}
        page << "$('suggestions').remove();"
      end
    else
      respond_to do |format|
        format.html do
            render 'index'
        end
        format.js
      end
    end
  end
  
  def unauthorized_user
    notice_msg = 'Please login or register as a teacher'
    redirect_url = root_url
    
    # Set notice message
    flash[:notice] = notice_msg
    
    # Redirect to the login page
    redirect_to redirect_url
  end
  
  def setup_material_type
    @material_type = param_find(:material, (params[:method] == :get)) ||
      (current_project.include_external_activities? ? ['investigation','activity','external_activity'] : ['investigation','activity'])
  end

  def get_searchoptions
    unless params[:search_term].nil?
      @search_term = params[:search_term].strip
    end
    @sort_order = param_find(:sort_order, (params[:method] == :get)) || 'name ASC'

    # we expect this to always return an array in our view
    @domain_id  = [param_find(:domain_id, (params[:method] == :get)) || []].flatten.uniq.compact

    @grade_span = param_find(:grade_span, (params[:method] == :get)) || ""
    if (@grade_span).class == String && @grade_span.length>0 
      @grade_span= @grade_span.split('&')
    end
    @investigation_page=params[:investigation_page]|| 1
    @activity_page = params[:activity_page] || 1
    @external_activity_page = params[:external_activity_page] || 1
    setup_material_type
    @probe_type = param_find(:probe, (params[:method] == :get)) || []
    
    # from cookies, this comes back as as single string sometimes.
    # see features/teacher_filters_instructional_materials.feature:80
    # TODO: this should all be simplified and cleaned up.
    if @probe_type.class == String
      @probe_type = [@probe_type]
    end
    if current_visitor.anonymous?
      @without_teacher_only=true
    end
    
    search_options = {
      :name => @search_term || '',
      :sort_order => @sort_order,
      :domain_id => @domain_id || [],
      :grade_span => @grade_span|| [],
      :paginate => false,
      :probe_type => @probe_type,
      :user => current_visitor,
      :without_teacher_only =>@without_teacher_only || false
      #:page => params[:investigation_page] ? params[:investigation_page] : 1,
      #:per_page => 10
    }
    return search_options
  end
  
  def get_search_suggestions
    @search_term = params[:search_term]
    @domain_id  = [param_find(:domain_id, (params[:method] == :get)) || []].flatten.uniq.compact
    @grade_span = param_find(:grade_span, (params[:method] == :get)) || ""
    if (@grade_span).class == String && @grade_span.length>0 
      @grade_span= @grade_span.split('&')
    end
    @probe_type = param_find(:probe, (params[:method] == :get)) || []
    setup_material_type
    investigations=[]
    activities=[]
    external_activities=[]
    ajaxResponseCounter = params[:ajaxRequestCounter]
    submitform = params[:submit_form]
    if current_visitor.anonymous?
      @without_teacher_only=true
    end
    search_options = {
      :name => @search_term,
      :sort_order => 'name ASC',
      :domain_id => @domain_id || [],
      :grade_span => @grade_span|| [],
      :probe_type => @probe_type,
      :user => current_visitor,
      :without_teacher_only =>@without_teacher_only || false
    }
    
    if @material_type.include?('investigation')
      investigations = Investigation.search_list(search_options)
    end
    if @material_type.include?('activity')
      activities = Activity.search_list(search_options)
    end
    if @material_type.include?('external_activity') && current_project.include_external_activities
      external_activities = ExternalActivity.search_list(search_options)
    end

    @suggestions= [];
    @suggestions = investigations + activities + external_activities
    if request.xhr?
       render :update do |page|
         page << "if (ajaxRequestCounter == #{ajaxResponseCounter}) {"
         page.replace_html 'search_suggestions', {:partial => 'search/search_suggestions',:locals=>{:textlength=>@search_term.length,:investigations=>investigations,:activities=>activities,:external_activities=>external_activities,:submit_form=>submitform}}
         page << '}'
       end
    end
  end
  
  def find_material(type, id)
    material = nil
    if ["Investigation", "Activity", "Page", "ExternalActivity", "ResourcePage"].include?(type)  # this is for safety
      material = type.constantize.find(id)
    end
    
    return material
  end
  
  def get_current_material_unassigned_clazzes
    material_type = params[:material_type]
    material_ids = params[:material_id]
    material_ids = material_ids.split(',')
    
    teacher_clazzes = current_visitor.portal_teacher.teacher_clazzes.sort{|a,b| a.position <=> b.position}
    teacher_clazzes = teacher_clazzes.select{|item| item.active == true}
    teacher_clazz_ids = teacher_clazzes.map{|item| item.clazz_id}
    
    if material_ids.length == 1 #Check if material to be assigned is a single activity or investigation 
      @material = [find_material(material_type, params[:material_id])]
      
      teacher_offerings = Portal::Offering.where(:runnable_id=>params[:material_id], :runnable_type=>params[:material_type], :clazz_id=>teacher_clazz_ids)
      assigned_clazz_ids = teacher_offerings.map{|item| item.clazz_id}
      
      
      @assigned_clazzes = Portal::Clazz.where(:id=>assigned_clazz_ids)
      @assigned_clazzes = @assigned_clazzes.sort{|a,b| teacher_clazz_ids.index(a.id) <=> teacher_clazz_ids.index(b.id)}
    else
      @assigned_clazzes = []
      assigned_clazz_ids = []
      @material = material_ids.collect{|a| ::Activity.find(a)}
    end
    
    unassigned_teacher_clazzes = teacher_clazzes.select{|item| assigned_clazz_ids.index(item.clazz_id).nil?}
    @unassigned_clazzes = Portal::Clazz.where(:id=>unassigned_teacher_clazzes.map{|item| item.clazz_id})
    @unassigned_clazzes = @unassigned_clazzes.sort{|a,b| teacher_clazz_ids.index(a.id) <=> teacher_clazz_ids.index(b.id)}
    
    @teacher_active_clazzes_count = (teacher_clazzes)? teacher_clazzes.length : 0
    render :partial => 'material_unassigned_clazzes'
  end
  
  def add_material_to_clazzes
    clazz_ids = params[:clazz_id] || []
    runnable_ids = params[:material_id].split(',')
    runnable_type = params[:material_type].classify
    assign_summary_data = []
    
    clazz_ids.each do|clazz_id|
      already_assigned_material_names = []
      newly_assigned_material_names = []
      portal_clazz = Portal::Clazz.find(clazz_id)
      runnable_ids.each do|runnable_id|
        portal_clazz_offerings = portal_clazz.offerings
        portal_offering = portal_clazz_offerings.find_by_runnable_id_and_runnable_type(runnable_id,runnable_type)
        if portal_offering.nil?
          offering = Portal::Offering.find_or_create_by_clazz_id_and_runnable_type_and_runnable_id(portal_clazz.id,runnable_type,runnable_id)
          if offering.position == 0
            offering.position = portal_clazz.offerings.length
            offering.save
          end
          newly_assigned_material_names << offering.name
        else
          already_assigned_material_names << portal_offering.name
        end
      end
      assign_summary_data << [portal_clazz.name, newly_assigned_material_names,already_assigned_material_names]
    end
    
    if request.xhr?
      render :update do |page|
        if runnable_ids.length == 1
          material_parent = nil
          if runnable_type == "Investigation"
            material = ::Investigation.find(params[:material_id])
            used_in_clazz_count = material.offerings.count
          elsif runnable_type == "Activity"
            material = ::Activity.find(params[:material_id])
            material_parent = material.parent
            used_in_clazz_count = (material_parent)? material_parent.offerings.count : material.offerings.count
          elsif runnable_type == "ExternalActivity"
            material = ::ExternalActivity.find(params[:material_id])
            used_in_clazz_count = material.offerings.count
          end
          
          if(used_in_clazz_count == 0)
            class_count_desc = "Not used in any class."
          elsif(used_in_clazz_count == 1)
            class_count_desc = "Used in 1 class."
          else
            class_count_desc = "Used in #{used_in_clazz_count} classes."
          end
        
          if clazz_ids.count > 0
            page << "close_popup()"
            page << "getMessagePopup('<div class=\"feedback_message\">#{runnable_type} is assigned to the selected class(es) successfully.</div>')"
            page.replace_html "material_clazz_count", class_count_desc
            if !material_parent.nil? && runnable_type == "Activity"
              used_in_clazz_count = material.offerings.count + material.parent.offerings.count
              
              if(used_in_clazz_count == 0)
                class_count_desc = "Not used in any class."
              elsif(used_in_clazz_count == 1)
                class_count_desc = "Used in 1 class."
              else
                class_count_desc = "Used in #{used_in_clazz_count} classes."
              end
              page.replace_html "activity_clazz_count_#{runnable_ids[0]}", class_count_desc
            end
            
            if runnable_type == "Investigation"
              material.activities.each do|activity|
                used_in_clazz_count = activity.offerings.count + material.offerings.count
                
                if(used_in_clazz_count == 0)
                  class_count_desc = "Not used in any class."
                elsif(used_in_clazz_count == 1)
                  class_count_desc = "Used in 1 class."
                else
                  class_count_desc = "Used in #{used_in_clazz_count} classes."
                end
                
                page.replace_html "activity_clazz_count_#{activity.id}", class_count_desc
                
              end
            end
            #page.replace_html "search_#{runnable_type.downcase}_#{runnable_id}", {:partial => 'result_item', :locals=>{:material=>material}}
          else
            page << "$('error_message').update('Select atleast one class to assign this #{runnable_type}');$('error_message').show()"
          end
        else
          if clazz_ids.count > 0
            runnable_ids.each do|runnable_id|
              material = ::Activity.find(runnable_id)
              used_in_clazz_count = material.offerings.count + material.parent.offerings.count
              
              if(used_in_clazz_count == 0)
                class_count_desc = "Not used in any class."
              elsif(used_in_clazz_count == 1)
                class_count_desc = "Used in 1 class."
              else
                class_count_desc = "Used in #{used_in_clazz_count} classes."
              end
              page.replace_html "activity_clazz_count_#{runnable_id}", class_count_desc
              
            end
            page.replace_html "clazz_summary_data", {:partial => 'material_assign_summary', :locals=>{:summary_data=>assign_summary_data}}
            page << "setPopupHeight()"
          else
            page << "$('error_message').update('Select atleast one class to assign this #{runnable_type}');$('error_message').show()"
          end  
          
        end
      end
    end
  end
  
end
