class RiGse::DomainsController < ApplicationController
  # GET /RiGse/domains
  # GET /RiGse/domains.xml
  def index
    @domains = RiGse::Domain.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @domains }
    end
  end

  # GET /RiGse/domains/1
  # GET /RiGse/domains/1.xml
  def show
    @domain = RiGse::Domain.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @domain }
    end
  end

  # GET /RiGse/domains/new
  # GET /RiGse/domains/new.xml
  def new
    @domain = RiGse::Domain.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @domain }
    end
  end

  # GET /RiGse/domains/1/edit
  def edit
    @domain = RiGse::Domain.find(params[:id])
  end

  # POST /RiGse/domains
  # POST /RiGse/domains.xml
  def create
    @domain = RiGse::Domain.new(params[:domain])

    respond_to do |format|
      if @domain.save
        flash[:notice] = 'RiGse::Domain.was successfully created.'
        format.html { redirect_to(@domain) }
        format.xml  { render :xml => @domain, :status => :created, :location => @domain }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @domain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/domains/1
  # PUT /RiGse/domains/1.xml
  def update
    @domain = RiGse::Domain.find(params[:id])

    respond_to do |format|
      if @domain.update_attributes(params[:domain])
        flash[:notice] = 'RiGse::Domain.was successfully updated.'
        format.html { redirect_to(@domain) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @domain.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/domains/1
  # DELETE /RiGse/domains/1.xml
  def destroy
    @domain = RiGse::Domain.find(params[:id])
    @domain.destroy

    respond_to do |format|
      format.html { redirect_to(domains_url) }
      format.xml  { head :ok }
    end
  end
end
