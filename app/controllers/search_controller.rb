class SearchController < ApplicationController

  include RestrictedController

  before_filter :teacher_only, :only => [:index, :show]
  before_filter :check_if_teacher, :only => [:get_current_material_unassigned_clazzes, :add_material_to_clazzes]
  before_filter :admin_only, :only => [:get_current_material_unassigned_collections, :add_material_to_collections]

  protected

  def teacher_only
    if current_visitor.portal_student
      redirect_to(:root)
    end
  end

  def check_if_teacher
    if current_visitor.portal_teacher.nil? && request.xhr?
      respond_to do |format|
        format.js { render :json => "Not Teacher",:status => 401 }
      end
    end
  end

  in_place_edit_for :investigation, :search_term

  public

  def index
    return redirect_to action: 'index', include_official: '1' if request.query_parameters.empty?
    opts = params.merge(:user_id => current_visitor.id, :skip_search => true)
    begin
      @form_model = Search.new(opts)
    rescue => e
      ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver
      render :search_unavailable
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
    @material_type = param_find(:material_types, (params[:method] == :get)) ||
      (current_settings.include_external_activities? ? ['investigation','activity','external_activity'] : ['investigation','activity'])
  end


  def get_search_suggestions
    setup_material_type
    search_term         = params[:search_term]
    ajaxResponseCounter = params[:ajaxRequestCounter]
    submitform          = params[:submit_form]
    other_params = {
      :without_teacher_only => current_visitor.anonymous?,
      :sort_order => Search::Score,
      :user_id => current_visitor.id
    }
    search = Search.new(params.merge(other_params))
    suggestions= search.results[:all]
    if request.xhr?
       render :update do |page|
         page << "if (ajaxRequestCounter == #{ajaxResponseCounter}) {"
         page.replace_html 'search_suggestions', {
          :partial => 'search/search_suggestions',
          :locals=> {
            :textlength  => search_term.length,
            :suggestions => suggestions,
            :submit_form => submitform}}
         page << "addSuggestionClickHandlers();"
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
            used_in_clazz_count = material.offerings_count
          elsif runnable_type == "Activity"
            material = ::Activity.find(params[:material_id])
            material_parent = material.parent
            used_in_clazz_count = (material_parent)? material_parent.offerings_count : material.offerings_count
          elsif runnable_type == "ExternalActivity"
            material = ::ExternalActivity.find(params[:material_id])
            used_in_clazz_count = material.offerings_count
            runnable_display_name = material.template_type
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
            page << "getMessagePopup('<div class=\"feedback_message\"><b>#{material.name.gsub("'","\\'")}</b> is assigned to the selected class(es) successfully.</div>')"
            page.replace_html "material_clazz_count", class_count_desc
            if !material_parent.nil? && runnable_type == "Activity"
              used_in_clazz_count = material.offerings_count + material.parent.offerings_count

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
                used_in_clazz_count = activity.offerings_count + material.offerings_count

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
          else
            page << "$('error_message').update('Select at least one class to assign this #{runnable_type}');$('error_message').show()"
          end
        else
          if clazz_ids.count > 0
            runnable_ids.each do|runnable_id|
              material = ::Activity.find(runnable_id)
              used_in_clazz_count = material.offerings_count + material.parent.offerings_count

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
            page << "$('error_message').update('Select at least one class to assign this #{runnable_type}');$('error_message').show()"
          end

        end
      end
    end
  end

  def get_current_material_unassigned_collections
    material_type = params[:material_type]
    material_ids = params[:material_id]
    material_ids = material_ids.split(',')

    @collections = MaterialsCollection.includes(:materials_collection_items).all

    if material_ids.length == 1 #Check if material to be assigned is a single activity or investigation
      @material = [find_material(material_type, params[:material_id])]
      @assigned_collections = @collections.select{|c| _collection_has_materials(c, @material) }
    else
      @material = material_ids.collect{|a| ::Activity.find(a)}
      @assigned_collections = []
    end

    @unassigned_collections = @collections - @assigned_collections

    render :partial => 'material_unassigned_collections'
  end

  def add_material_to_collections
    collection_ids = params[:materials_collection_id] || []
    runnable_ids = params[:material_id].split(',')
    runnable_type = params[:material_type].classify
    assign_summary_data = []

    collection_ids.each do|collection_id|
      already_assigned_material_names = []
      newly_assigned_material_names = []
      collection = MaterialsCollection.includes(:materials_collection_items).find(collection_id)
      runnable_ids.each do|runnable_id|
        collection_items = collection.materials_collection_items
        item = collection_items.find_by_material_id_and_material_type(runnable_id,runnable_type)
        if item.nil?
          item = MaterialsCollectionItem.find_or_create_by_materials_collection_id_and_material_type_and_material_id(collection.id,runnable_type,runnable_id)
          if item.position.nil?
            item.position = collection_items.length
            item.save
          end
          newly_assigned_material_names << collection.name
        else
          already_assigned_material_names << collection.name
        end
      end
      assign_summary_data << [collection.name, newly_assigned_material_names,already_assigned_material_names]
    end

    if request.xhr?
      render :update do |page|
        materials = []
        if runnable_ids.length == 1
          if runnable_type == "Investigation"
            materials.push ::Investigation.find(params[:material_id])
          elsif runnable_type == "Activity"
            materials.push ::Activity.find(params[:material_id])
          elsif runnable_type == "ExternalActivity"
            materials.push ::ExternalActivity.find(params[:material_id])
          end
        else
          runnable_ids.each do |id|
            materials.push ::Activity.find(id)
          end
        end

        if collection_ids.count > 0
          material_names = materials.map {|m| "<b>#{m.name}</b>" }.join(", ").gsub("'","\\'")
          page << "close_popup()"
          page << "getMessagePopup('<div class=\"feedback_message\">#{material_names} #{'is'.pluralize(runnable_ids.length)} assigned to the selected collection(s) successfully.</div>')"
        else
          page << "$('error_message').update('Select at least one collection to assign this #{runnable_type}');$('error_message').show()"
        end
      end
    end
  end

  private

  def _collection_has_materials(collection, materials)
    items = collection.materials_collection_items.map{|i| [i.material_type, i.material_id] }
    material_items = materials.map {|m| [m.class.to_s, m.id] }

    has_them_all = (material_items - items).empty? && (material_items & items).length == material_items.length
    return has_them_all
  end
end
