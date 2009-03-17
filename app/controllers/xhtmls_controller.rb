class XhtmlsController < ApplicationController
  # GET /xhtmls
  # GET /xhtmls.xml
  def index
    @xhtmls = Xhtml.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @xhtmls }
    end
  end

  # GET /xhtmls/1
  # GET /xhtmls/1.xml
  def show
    @xhtml = Xhtml.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @xhtml }
    end
  end

  # GET /xhtmls/new
  # GET /xhtmls/new.xml
  def new
    @xhtml = Xhtml.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @xhtml }
    end
  end

  # GET /xhtmls/1/edit
  def edit
    @xhtml = Xhtml.find(params[:id])
  end

  # POST /xhtmls
  # POST /xhtmls.xml
  def create
    @xhtml = Xhtml.new(params[:xhtml])

    respond_to do |format|
      if @xhtml.save
        flash[:notice] = 'Xhtml was successfully created.'
        format.html { redirect_to(@xhtml) }
        format.xml  { render :xml => @xhtml, :status => :created, :location => @xhtml }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /xhtmls/1
  # PUT /xhtmls/1.xml
  def update
    @xhtml = Xhtml.find(params[:id])

    respond_to do |format|
      if @xhtml.update_attributes(params[:xhtml])
        flash[:notice] = 'Xhtml was successfully updated.'
        format.html { redirect_to(@xhtml) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @xhtml.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /xhtmls/1
  # DELETE /xhtmls/1.xml
  def destroy
    @xhtml = Xhtml.find(params[:id])
    @xhtml.destroy

    respond_to do |format|
      format.html { redirect_to(xhtmls_url) }
      format.xml  { head :ok }
    end
  end
end
