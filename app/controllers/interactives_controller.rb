class InteractivesController < ApplicationController
  
  before_filter :admin_only, :except => [:index, :show, :export_model_library]

  def index
    search_params = {
      :material_types     => [Search::InteractiveMaterial],
      :interactive_page   => params[:page],
      :per_page           => 30,
      :user_id            => current_visitor.id,
      :private            => current_visitor.has_role?('admin'),
      :search_term        => params[:search]
    }

    s = Search.new(search_params)
    @interactives = s.results[Search::InteractiveMaterial]

    if params[:mine_only]
      @interactives = @interactives.reject { |i| i.user.id != current_visitor.id }
    end

    if request.xhr?
      render :partial => 'interactives/index', :locals => {:interactives => @interactives, :paginated_objects =>@interactives}
    else
      respond_to do |format|
        format.html do
          render 'index'
        end
        format.js
      end
    end
  end
  
  def new
    @interactive = Interactive.new(:scale => 1.0, :width => 690, :height => 400)
  end
  
  def create
    @interactive = Interactive.new(params[:interactive])
    @interactive.user = current_visitor
    
    if params[:update_grade_levels]
      # set the grade_level tags
      @interactive.grade_level_list = (params[:grade_levels] || [])     
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @interactive.subject_area_list = (params[:subject_areas] || [])
    end

    if params[:update_model_types]
      # set the subject_area tags
      @interactive.model_type_list = (params[:model_types] || [])
    end

    respond_to do |format|
      if @interactive.save
        format.js  # render the js file
        flash[:notice] = 'Interactive was successfully created.'
        format.html { redirect_to(@interactive) }
        format.xml  { render :xml => @interactive, :status => :created, :location => @interactive }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @interactive.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show 
    @interactive = Interactive.find(params[:id])
  end

  def edit
    @interactive = Interactive.find(params[:id])
  end

  def destroy
    @interactive = Interactive.find(params[:id])
    @interactive.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end

  def update
    cancel = params[:commit] == "Cancel"
    @interactive = Interactive.find(params[:id])

    if params[:update_grade_levels]
      # set the grade_level tags
      @interactive.grade_level_list = (params[:grade_levels] || [])
      @interactive.save
    end

    if params[:update_subject_areas]
      # set the subject_area tags
      @interactive.subject_area_list = (params[:subject_areas] || [])
      @interactive.save
    end

    if params[:update_model_types]
      # set the subject_area tags
      @interactive.model_type_list = (params[:model_types] || [])
      @interactive.save
    end

    if request.xhr?
      if cancel || @interactive.update_attributes(params[:interactive])
        render 'show', :locals => { :interactive => @interactive }
      else
        render :xml => @interactive.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @interactive.update_attributes(params[:interactive])
          flash[:notice] = 'Interactive was successfully updated.'
          format.html { redirect_to(@interactive) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @interactive.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def import_model_library
    if request.post?
      respond_to do |format|
        begin
          model_library = JSON.parse( params['import'].read, :symbolize_names => true )
          Interactive.transaction do
            model_library[:models].each do |model|

              interactive = Interactive.new(model.except(:model_type))
              interactive.user = current_visitor
              interactive.publication_status = "draft"

              if model[:model_type]
                new_admin_tag = {:scope => "model_types", :tag => model[:model_type]}
                if Admin::Tag.fetch_tag(new_admin_tag).size == 0
                  admin_tag = Admin::Tag.new({:scope => "model_types", :tag => model[:model_type]})
                  admin_tag.save!
                end
                interactive.model_type_list.add(model[:model_type])
              end

              if interactive.save!
                format.js { render :js => "window.location.href = 'interactives';" }
              else
                format.js { render :json => { :error =>"Import Failed"}, :status => 500 }
              end

            end
          end
        rescue => e
          format.js  { render :json => { :error =>"JSON Parser Error"}, :status => 500 }
        end
      end
    else
      @message = params[:message] || ''
      respond_to do |format|
        format.js { render :json => { :html => render_to_string('import_model_library')}, :content_type => 'text/json' }
        format.html
      end
    end
  end

  def export_model_library
    model_library = []
    Interactive.published.each do |m|
      model_library << {
        :name => m.name,
        :description => m.description,
        :url => m.url,
        :width => m.width,
        :height => m.height,
        :scale => m.scale,
        :image_url => m.image_url,
        :credits => m.credits,
        :model_type => m.model_type_list[0]
      }
    end
    model_library = {:models => model_library }
    send_data model_library.to_json, :type => :json, :disposition => "attachment", :filename => "portal_interactives_library.json"
  end

  protected
  def admin_only
    unless current_visitor.has_role?('admin')
      flash[:notice] = "Please log in as an administrator"
      redirect_to(:home)
    end
  end
end
