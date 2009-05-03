class DataTablesController < ApplicationController
  # GET /data_tables
  # GET /data_tables.xml
  def index    
    @data_tables = DataTable.search(params[:search], params[:page], self.current_user)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_tables}
    end
  end

  # GET /data_tables/1
  # GET /data_tables/1.xml
  def show
    @data_table = DataTable.find(params[:id])
    if request.xhr?
      render :partial => 'data_table', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/data_table" } # data_table.otml.haml
        format.xml  { render :xml => @data_table }
      end
    end
  end

  # GET /data_tables/1/print
  def print
    @data_table = DataTable.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "layouts/print" }
      format.xml  { render :xml => @data_table }
    end
  end

  # GET /data_tables/new
  # GET /data_tables/new.xml
  def new
    @data_table = DataTable.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html { render :partial=>'data_table', :locals => { :data_table => @data_table }, :layout=>false }
        format.xml  { render :xml => @data_table }
      end
    end
  end

  # GET /data_tables/1/edit
  def edit
    @data_table = DataTable.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @data_table  }
      end
    end
  end
  

  # POST /data_tables
  # POST /data_tables.xml
  def create
    @data_table = DataTable.new(params[:xhtml])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @data_table.save
        render :partial => 'new', :locals => { :data_table => @data_table }
      else
        render :xml => @data_table.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @data_table.save
          flash[:notice] = 'Datatable was successfully created.'
          format.html { redirect_to(@data_table) }
          format.xml  { render :xml => @data_table, :status => :created, :location => @data_table }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @data_table.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /data_tables/1
  # PUT /data_tables/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @data_table = DataTable.find(params[:id])
    if request.xhr?
      if cancel || @data_table.update_attributes(params[:data_table])
        render :partial => 'show', :locals => { :data_table => @data_table }
      else
        render :xml => @data_table.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @data_table.update_attributes(params[:data_table])
          flash[:notice] = 'Datatable was successfully updated.'
          format.html { redirect_to(@data_table) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @data_table.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /data_tables/1
  # DELETE /data_tables/1.xml
  def destroy
    @data_table = DataTable.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(data_tables_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @data_table.page_elements.each do |pe|
      pe.destroy
    end
    @data_table.destroy    
  end
end
