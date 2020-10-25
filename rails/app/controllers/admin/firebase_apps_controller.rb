class Admin::FirebaseAppsController < ApplicationController
  # GET /admin/firebase_apps
  # GET /admin/firebase_apps.json
  def index
    authorize FirebaseApp
    @firebase_apps = FirebaseApp.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @firebase_apps }
    end
  end

  # GET /admin/firebase_apps/1
  # GET /admin/firebase_apps/1.json
  def show
    @firebase_app = FirebaseApp.find(params[:id])
    authorize @firebase_app

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @firebase_app }
    end
  end

  # GET /admin/firebase_apps/new
  # GET /admin/firebase_apps/new.json
  def new
    authorize FirebaseApp
    @firebase_app = FirebaseApp.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @firebase_app }
    end
  end

  # GET /admin/firebase_apps/1/edit
  def edit
    @firebase_app = FirebaseApp.find(params[:id])
    authorize @firebase_app
  end

  # POST /admin/firebase_apps
  # POST /admin/firebase_apps.json
  def create
    authorize FirebaseApp
    @firebase_app = FirebaseApp.new(params[:firebase_app])

    respond_to do |format|
      if @firebase_app.save
        format.html { redirect_to admin_firebase_apps_path, notice: 'Firebase app was successfully created.' }
        format.json { render json: @firebase_app, status: :created, location: @firebase_app }
      else
        format.html { render action: "new" }
        format.json { render json: @firebase_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/firebase_apps/1
  # PATCH/PUT /admin/firebase_apps/1.json
  def update
    @firebase_app = FirebaseApp.find(params[:id])
    authorize @firebase_app

    respond_to do |format|
      if @firebase_app.update_attributes(params[:firebase_app])
        format.html { redirect_to admin_firebase_apps_path, notice: 'Firebase app was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @firebase_app.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/firebase_apps/1
  # DELETE /admin/firebase_apps/1.json
  def destroy
    @firebase_app = FirebaseApp.find(params[:id])
    authorize @firebase_app
    @firebase_app.destroy

    respond_to do |format|
      format.html { redirect_to admin_firebase_apps_path, notice: 'Firebase app was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
