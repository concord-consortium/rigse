class Diy::ModelsController < ApplicationController
  # GET /Embeddable/embedded_models
  # GET /Embeddable/embedded_models.xml
  def index
    @models = Diy::Model.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @models }
    end
  end

  # # GET /Embeddable/embedded_models/1
  # # GET /Embeddable/embedded_models/1.xml
  # def show
  #   @model_type = Diy::ModelType.find(params[:id])
  #   if request.xhr?
  #     render :partial => 'show', :locals => { :model_types => @model_type }
  #   else
  #     respond_to do |format|
  #       format.html # show.html.erb
  #       format.xml  { render :xml => @model_type }
  #     end
  #   end
  # end
  # 
  # # GET /Embeddable/embedded_models/new
  # # GET /Embeddable/embedded_models/new.xml
  # def new
  #   @model_type = Diy::ModelType.new
  #   if request.xhr?
  #     render :partial => 'remote_form', :locals => { :model_types => @model_type }
  #   else
  #     respond_to do |format|
  #       format.html
  #       format.xml  { render :xml => @model_type }
  #     end
  #   end
  # end
  # 
  # # GET /Embeddable/embedded_models/1/edit
  # def edit
  #   @model_type = Diy::ModelType.find(params[:id])
  #   if request.xhr?
  #     render :partial => 'remote_form', :locals => { :model_types => @model_type }
  #   else
  #     respond_to do |format|
  #       format.html 
  #       format.xml  { render :xml => @model_type }
  #     end
  #   end
  # end
  # 
  # # POST /Embeddable/embedded_models
  # # POST /Embeddable/embedded_models.xml
  # def create
  #   @model_type = Diy::ModelType.new(params[:embedded_model])
  #   cancel = params[:commit] == "Cancel"
  #   if request.xhr?
  #     if cancel 
  #       redirect_to :index
  #     elsif @model_type.save
  #       render :partial => 'new', :locals => { :model_types => @model_type }
  #     else
  #       render :xml => @model_type.errors, :status => :unprocessable_entity
  #     end
  #   else
  #     respond_to do |format|
  #       if @model_type.save
  #         flash[:notice] = 'Diy::ModelType.was successfully created.'
  #         format.html { redirect_to(@model_type) }
  #         format.xml  { render :xml => @model_type, :status => :created, :location => @model_type }
  #       else
  #         format.html { render :action => "new" }
  #         format.xml  { render :xml => @model_type.errors, :status => :unprocessable_entity }
  #       end
  #     end
  #   end
  # end
  # 
  # # DELETE /Embeddable/embedded_models/1
  # # DELETE /Embeddable/embedded_models/1.xml
  # def destroy
  #   @model_type = Diy::ModelType.find(params[:id])
  #   respond_to do |format|
  #     format.html { redirect_to(model_types_url) }
  #     format.xml  { head :ok }
  #     format.js
  #   end
  #   
  #   @model_type.destroy    
  # end
end
