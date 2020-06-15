class Admin::AuthoringSitesController < ApplicationController
  # GET /admin/authoring_sites
  # GET /admin/authoring_sites.json
  def index
    authorize Admin::AuthoringSite
    @admin_authoring_sites = Admin::AuthoringSite.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_authoring_sites }
    end
  end

  # GET /admin/authoring_sites/1
  # GET /admin/authoring_sites/1.json
  def show
    @admin_authoring_site = Admin::AuthoringSite.find(params[:id])
    authorize @admin_authoring_site

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_authoring_site }
    end
  end

  # GET /admin/authoring_sites/new
  # GET /admin/authoring_sites/new.json
  def new
    authorize Admin::AuthoringSite
    @admin_authoring_site = Admin::AuthoringSite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_authoring_site }
    end
  end

  # GET /admin/authoring_sites/1/edit
  def edit
    @admin_authoring_site = Admin::AuthoringSite.find(params[:id])
    authorize @admin_authoring_site
  end

  # POST /admin/authoring_sites
  # POST /admin/authoring_sites.json
  def create
    authorize Admin::AuthoringSite
    @admin_authoring_site = Admin::AuthoringSite.new(admin_authoring_site_params)

    respond_to do |format|
      if @admin_authoring_site.save
        format.html { redirect_to @admin_authoring_site, notice: 'Authoring site was successfully created.' }
        format.json { render json: @admin_authoring_site, status: :created, location: @admin_authoring_site }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_authoring_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/authoring_sites/1
  # PATCH/PUT /admin/authoring_sites/1.json
  def update
    @admin_authoring_site = Admin::AuthoringSite.find(params[:id])
    authorize @admin_authoring_site

    respond_to do |format|
      if @admin_authoring_site.update_attributes(admin_authoring_site_params)
        format.html { redirect_to @admin_authoring_site, notice: 'Authoring site was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_authoring_site.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/authoring_sites/1
  # DELETE /admin/authoring_sites/1.json
  def destroy
    @admin_authoring_site = Admin::AuthoringSite.find(params[:id])
    authorize @admin_authoring_site
    @admin_authoring_site.destroy

    respond_to do |format|
      format.html { redirect_to admin_authoring_sites_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def admin_authoring_site_params
      params.require(:admin_authoring_site).permit(:name, :url)
    end
end
