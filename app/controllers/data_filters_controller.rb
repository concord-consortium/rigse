class DataFiltersController < ApplicationController
  # GET /data_filters
  # GET /data_filters.xml
  def index
    @data_filters = DataFilter.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_filters }
    end
  end

  # GET /data_filters/1
  # GET /data_filters/1.xml
  def show
    @data_filter = DataFilter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @data_filter }
    end
  end

  # GET /data_filters/new
  # GET /data_filters/new.xml
  def new
    @data_filter = DataFilter.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_filter }
    end
  end

  # GET /data_filters/1/edit
  def edit
    @data_filter = DataFilter.find(params[:id])
  end

  # POST /data_filters
  # POST /data_filters.xml
  def create
    @data_filter = DataFilter.new(params[:data_filter])

    respond_to do |format|
      if @data_filter.save
        flash[:notice] = 'DataFilter was successfully created.'
        format.html { redirect_to(@data_filter) }
        format.xml  { render :xml => @data_filter, :status => :created, :location => @data_filter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @data_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_filters/1
  # PUT /data_filters/1.xml
  def update
    @data_filter = DataFilter.find(params[:id])

    respond_to do |format|
      if @data_filter.update_attributes(params[:data_filter])
        flash[:notice] = 'DataFilter was successfully updated.'
        format.html { redirect_to(@data_filter) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @data_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_filters/1
  # DELETE /data_filters/1.xml
  def destroy
    @data_filter = DataFilter.find(params[:id])
    @data_filter.destroy

    respond_to do |format|
      format.html { redirect_to(data_filters_url) }
      format.xml  { head :ok }
    end
  end
end
