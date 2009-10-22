class DataCollectorsController < ApplicationController


  protected
  def changed_calibration?(calibration_id)
    if session[:calibration_id] == calibration_id
      return false
    end
    true
  end
  
  def changed_probe_type?(probe_type_id)
    if session[:probe_type_id] == probe_type_id
      return false
    end
    true
  end
  
  public
  
  # GET /data_collectors
  # GET /data_collectors.xml
  def index
    @data_collectors = DataCollector.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @data_collectors }
    end
  end

  # GET /data_collectors/1
  # GET /data_collectors/1.xml
  def show
    @authoring = false
    @data_collector = DataCollector.find(params[:id])
    if request.xhr?
      render :partial => 'data_collector', :locals => { :data_collector => @data_collector }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/data_collector" } # data_collector.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @data_collector }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @data_collector, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @data_collector, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => @data_collector }
      end
    end
  end

  # GET /data_collectors/1/print
  def print
    @data_collector = DataCollector.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @data_collector }
    end
  end

  # GET /data_collectors/new
  # GET /data_collectors/new.xml
  def new
    if probe_type_id = session[:last_saved_probe_type_id]
      @data_collector = DataCollector.new(:probe_type_id => probe_type_id)
    else
      @data_collector = DataCollector.new
    end
    
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_collector => @data_collector }
    else
      respond_to do |format|
        format.html
        format.xml  { render :xml => @data_collector }
      end
    end
  end

  # GET /data_collectors/1/edit
  def edit
    @authoring = true
    @data_collector = DataCollector.find(params[:id])
    @scope = get_scope(@data_collector)
    session[:last_saved_probe_type_id] = @data_collector.probe_type_id
    session[:new_probe_type_id] = nil
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_collector => @data_collector, :scope => @scope }
    else
      respond_to do |format|
        format.html
        format.otml { render :layout => "layouts/data_collector" } # data_collector.otml.haml
        format.jnlp { render :partial => 'shared/edit', :locals => { :runnable => @data_collector } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @data_collector } }
        format.xml  { render :xml => @data_collector }
      end
    end
  end

  # POST /data_collectors
  # POST /data_collectors.xml
  def create
    @data_collector = DataCollector.new(params[:data_collector])
    session[:last_saved_probe_type_id] = @data_collector.probe_type_id
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @data_collector.save
        render :partial => 'new', :locals => { :data_collector => @data_collector }
      else
        render :xml => @data_collector.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if cancel 
          redirect_to :index
        elsif @data_collector.save
          flash[:notice] = 'DataCollector was successfully created.'
          format.html { redirect_to(@data_collector) }
          format.xml  { render :xml => @data_collector, :status => :created, :location => @data_collector }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @data_collector.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /data_collectors/1
  # PUT /data_collectors/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @data_collector = DataCollector.find(params[:id])

    # FixMe [this has at least been moved out of the model -n]
    # If the probe_type is changed set a new default name based on the 
    # title. This action assumes that the probe_type was changed using
    # using the standard edit page for a data_collector. This change on
    # the edit page uses an Ajax action (new_probe_type) to update the 
    # default values for the y-axis. This assmption will not necessarily
    # be correct with a REST update to this resource.
    if request.symbolized_path_parameters[:format] == 'otml'
      otml_root_content = (Hpricot.XML(request.raw_post)/'/otrunk/objects/OTSystem/root/*').to_s
      otml_library_content = (Hpricot.XML(request.raw_post)/'/otrunk/objects/OTSystem/library/*').to_s
      @data_collector.update_attributes(:otml_root_content => otml_root_content, :otml_library_content => otml_library_content)
      @data_collector.update_from_otml_library_content
      render :nothing => true
    else    
      if @data_collector.probe_type_id != params[:data_collector][:probe_type_id]
        params['data_collector']['name'] = params['data_collector']['title']
      end
      if request.xhr?
        if cancel || @data_collector.update_attributes(params[:data_collector])
          session[:last_saved_probe_type_id] = params[:data_collector][:probe_type_id]
          render :partial => 'show', :locals => { :data_collector => @data_collector }
        else
          render :xml => @data_collector.errors, :status => :unprocessable_entity
        end
      else
        respond_to do |format|
          if cancel || @data_collector.update_attributes(params[:data_collector])
            flash[:notice] = 'DataCollector was successfully updated.'
            session[:last_saved_probe_type_id] = params[:data_collector][:probe_type_id]
          
            format.html { redirect_to(@data_collector) }
            format.xml  { head :ok }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @data_collector.errors, :status => :unprocessable_entity }
          end
        end
      end
    end
  end

  # DELETE /data_collectors/1
  # DELETE /data_collectors/1.xml
  def destroy
    @data_collector = DataCollector.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(data_collectors_url) }
      format.xml  { head :ok }
      format.js
    end
    # TODO:  We should move this logic into the model!
    @data_collector.page_elements.each do |pe|
      pe.destroy
    end
    @data_collector.destroy
  end
    
  def changed_probe_info?(probe_type_id,calibration_id)
    return changed_probe_type?(probe_type_id) || changed_calibration?(calibration_id)
  end
  
  def change_probe_type
    probe_type_id = params[:data_collector][:probe_type_id]
    calibration_id = params[:data_collector][:calibration_id]
    # If probe_type or calibrations change, we change some other values.
    if changed_probe_info?(probe_type_id,calibration_id)
      @data_collector = DataCollector.find(params[:id])
      @scope = get_scope(@data_collector)
      @data_collector.probe_type = ProbeType.find(probe_type_id.to_i)
      @data_collector.title = "#{@data_collector.probe_type.name} Data Collector"
      @data_collector.y_axis_label = @data_collector.probe_type.name
      @data_collector.y_axis_units = @data_collector.probe_type.unit
      @data_collector.y_axis_min = @data_collector.probe_type.min
      @data_collector.y_axis_max = @data_collector.probe_type.max
      if changed_calibration?(calibration_id) 
        if calibration_id.to_i > 0
          @data_collector.calibration = Calibration.find(calibration_id.to_i)
          @data_collector.title = "#{@data_collector.calibration.name} Data Collector"
          @data_collector.y_axis_label = @data_collector.calibration.quantity
          @data_collector.y_axis_units = @data_collector.calibration.unit_symbol_text
        else
          @data_collector.calibration = nil
        end
      else
        @data_collector.calibration = nil
      end
      @data_collector.name = @data_collector.title
      session[:calibration_id]= calibration_id
      session[:probe_type_id]= probe_type_id
    else
      render :nothing => true;
    end
  end

end
