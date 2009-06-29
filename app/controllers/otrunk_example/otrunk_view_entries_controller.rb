class OtrunkExample::OtrunkViewEntriesController < ApplicationController
  # GET /otrunk_example_otrunk_view_entries
  # GET /otrunk_example_otrunk_view_entries.xml
  def index
    @otrunk_example_otrunk_view_entries = OtrunkExample::OtrunkViewEntry.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @otrunk_example_otrunk_view_entries }
    end
  end

  # GET /otrunk_example_otrunk_view_entries/1
  # GET /otrunk_example_otrunk_view_entries/1.xml
  def show
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @otrunk_view_entry }
    end
  end

  # GET /otrunk_example_otrunk_view_entries/new
  # GET /otrunk_example_otrunk_view_entries/new.xml
  def new
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @otrunk_view_entry }
    end
  end

  # GET /otrunk_example_otrunk_view_entries/1/edit
  def edit
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.find(params[:id])
  end

  # POST /otrunk_example_otrunk_view_entries
  # POST /otrunk_example_otrunk_view_entries.xml
  def create
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.new(params[:otrunk_view_entry])

    respond_to do |format|
      if @otrunk_view_entry.save
        flash[:notice] = 'OtrunkExample::OtrunkViewEntry was successfully created.'
        format.html { redirect_to(@otrunk_view_entry) }
        format.xml  { render :xml => @otrunk_view_entry, :status => :created, :location => @otrunk_view_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @otrunk_view_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /otrunk_example_otrunk_view_entries/1
  # PUT /otrunk_example_otrunk_view_entries/1.xml
  def update
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.find(params[:id])

    respond_to do |format|
      if @otrunk_view_entry.update_attributes(params[:otrunk_view_entry])
        flash[:notice] = 'OtrunkExample::OtrunkViewEntry was successfully updated.'
        format.html { redirect_to(@otrunk_view_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @otrunk_view_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /otrunk_example_otrunk_view_entries/1
  # DELETE /otrunk_example_otrunk_view_entries/1.xml
  def destroy
    @otrunk_view_entry = OtrunkExample::OtrunkViewEntry.find(params[:id])
    @otrunk_view_entry.destroy

    respond_to do |format|
      format.html { redirect_to(otrunk_example_otrunk_view_entries_url) }
      format.xml  { head :ok }
    end
  end
end
