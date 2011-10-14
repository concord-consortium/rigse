class Embeddable::DataTablesController < ApplicationController
  # GET /Embeddable/data_tables
  # GET /Embeddable/data_tables.xml
  def index    
    @teacher = false
    @data_tables = Embeddable::DataTable.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_tables}
    end
  end

  # GET /Embeddable/data_tables/1
  # GET /Embeddable/data_tables/1.xml
  def show
    @data_table = Embeddable::DataTable.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html # show.html.erb
        format.otml { render :layout => "layouts/embeddable/data_table" } # data_table.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => @data_table, :teacher_mode => false }}
        format.config { render :partial => 'shared/show', :locals => { :runnable => @data_table, :session_id => (params[:session] || request.env["rack.session.options"][:id]), :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @data_table, :teacher_mode => false} }
        format.xml  { render :xml => @data_table }
      end
    end
  end

  # GET /Embeddable/data_tables/new
  # GET /Embeddable/data_tables/new.xml
  def new
    @data_table = Embeddable::DataTable.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html { render :partial=>'data_table', :locals => { :data_table => @data_table }, :layout=>false }
        format.xml  { render :xml => @data_table }
      end
    end
  end

  # GET /Embeddable/data_tables/1/edit
  def edit
    @data_table = Embeddable::DataTable.find(params[:id])
    @scope = get_scope(@data_table)
    if request.xhr?
      render :partial => 'remote_form', :locals => { :data_table => @data_table }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @data_table  }
      end
    end
  end
  

  # POST /Embeddable/data_tables
  # POST /Embeddable/data_tables.xml
  def create
    @data_table = Embeddable::DataTable.new(params[:xhtml])
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

  # PUT /Embeddable/data_tables/1
  # PUT /Embeddable/data_tables/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @data_table = Embeddable::DataTable.find(params[:id])
    if request.xhr?
      if cancel || @data_table.update_attributes(params[:embeddable_data_table])
        render :partial => 'show', :locals => { :data_table => @data_table }
      else
        render :xml => @data_table.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @data_table.update_attributes(params[:embeddable_data_table])
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

  # DELETE /Embeddable/data_tables/1
  # DELETE /Embeddable/data_tables/1.xml
  def destroy
    @data_table = Embeddable::DataTable.find(params[:id])
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
  
  def update_cell_data
    @data_table = Embeddable::DataTable.find(params[:id])
    if @data_table.changeable? current_user
      @data_table.column_data = params[:data]
      if @data_table.save
        # TODO: give some good feedback to the author 
        # that the data has been updated.
        # render :update do |page|
        #   page << "debug('ok + #{@data_table.data}')"
        # end
      end
    end
    render :nothing => true
  end
end
