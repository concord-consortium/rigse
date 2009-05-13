class DataCollectorsController < ApplicationController
  # GET /data_collectors
  # GET /data_collectors.xml
  def index
    @data_collectors = DataCollector.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @data_collectors }
    end
  end

  # GET /data_collectors/1
  # GET /data_collectors/1.xml
  def show
    @data_collector = DataCollector.find(params[:id])
    if request.xhr?
      render :partial => 'data_collector', :locals => { :data_collector => @data_collector }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/data_collector" } # data_collector.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable_object => @data_collector } }
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
    @data_collector = DataCollector.new

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
    @data_collector = DataCollector.find(params[:id])
    session[:original_probe_type_id] = @data_collector.probe_type_id
    session[:new_probe_type_id] = nil
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_collector => @data_collector }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @data_collector }
      end
    end
  end

  # POST /data_collectors
  # POST /data_collectors.xml
  def create
    @data_collector = DataCollector.new(params[:data_collector])
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
    # FixMe
    # If the probe_type is changed set a new default name based on the 
    # title. This action assumes that the probe_type was changed using
    # using the standard edit page for a data_collector. This change on
    # the edit page uses an Ajax action (new_probe_type) to update the 
    # defaul values for the y-axis. This assmption will not necessarily
    # be correct with a REST update to this resource.
    if @data_collector.probe_type_id != params[:data_collector][:probe_type_id]
      params['data_collector']['name'] = params['data_collector']['title']
    end
    if request.xhr?
      if cancel || @data_collector.update_attributes(params[:data_collector])
        render :partial => 'show', :locals => { :data_collector => @data_collector }
      else
        render :xml => @data_collector.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if cancel || @data_collector.update_attributes(params[:data_collector])
          flash[:notice] = 'DataCollector was successfully updated.'
          format.html { redirect_to(@data_collector) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @data_collector.errors, :status => :unprocessable_entity }
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
  
  def change_probe_type
    @data_collector = DataCollector.find(params[:id])
    probe_type_id = params[:data_collector][:probe_type_id]
    case probe_type_id
    when session[:original_probe_type_id] && !session[:new_probe_type_id]
      render :nothing => true
    when session[:original_probe_type_id] && !session[:new_probe_type_id]
      session[:new_probe_type_id] = nil
    when session[:new_probe_type_id]
      @data_collector.update_attributes(params[:data_collector])
    else
      @data_collector.probe_type = ProbeType.find(probe_type_id)
      session[:new_probe_type_id] = probe_type_id
    end
  end
  
end
