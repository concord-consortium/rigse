class WebModelsController < ApplicationController
  include RestrictedController

  before_filter :admin_only

  before_filter :setup_object, :except => [:index]
  
  def setup_object
    if params[:id]
      if params[:id].length == 36
        @web_model = WebModel.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @web_model = WebModel.find(params[:id])
      end
    elsif params[:web_model]
      @web_model = WebModel.new(params[:web_model])
      @web_model.user = current_user
    else
      @web_model = WebModel.new
      @web_model.user = current_user
    end
  end
  
  
  # GET /web_models
  # GET /web_models.xml
  def index
    @web_models = WebModel.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @web_models }
    end
  end

  # GET /web_models/1
  # GET /web_models/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @web_model }
    end
  end

  # GET /web_models/new
  # GET /web_models/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @web_model }
    end
  end

  # GET /web_models/1/edit
  def edit
    respond_to do |format|
      format.js   { render :update do |page| 
        page.visual_effect :highlite, 'note' 
        end 
      }
    end
  end

  # POST /web_models
  # POST /web_models.xml
  def create
    if (@web_model.changeable?(current_user) && @web_model.update_attributes(params[:web_model]))      
      flash[:notice] = 'Web model was successfully created.'
      if (request.xhr?)
         render :text => "<div class='notice'>Web model saved</div>"
      else
        respond_to do |format|
          format.html { redirect_to(@web_model) }
          format.xml  { render :xml => @web_model, :status => :created, :location => @web_model }
        end
      end
    end
  end

  # PUT /web_models/1
  # PUT /web_models/1.xml
  def update
    if(@web_model.changeable?(current_user))
      if @web_model.update_attributes(params[:web_model])
        if (request.xhr?)
           render :text => "<div class='notice'>Web model saved</div>"
        else
          respond_to do |format|
            flash[:notice] = 'Web model was successfully created.'
            format.html { redirect_to(@web_model) }
            format.xml  { render :xml => @web_model, :status => :created, :location => @web_model }
          end
        end
      end
    else
      if (request.xhr?)
         render :text => "<div class='notice'>You can not create author notes</div>"
      else
        respond_to do |format|
          flash[:notice] = 'You can not create author notes'
          format.html { redirect_to(@web_model) }
          format.xml  { render :xml => @web_model, :status => :created, :location => @web_model }
        end
      end
    end
  end

  # DELETE /web_models/1
  # DELETE /web_models/1.xml
  def destroy
    if(@web_model.changeable?(current_user))
      @web_model.destroy
    end
    respond_to do |format|
      format.html { redirect_to(web_models_url) }
      format.xml  { head :ok }
    end
  end
end
