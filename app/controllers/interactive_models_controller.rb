class InteractiveModelsController < ApplicationController
  # GET /interactive_models
  # GET /interactive_models.xml
  def index
    @interactive_models = InteractiveModel.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @interactive_models }
    end
  end

  # GET /interactive_models/1
  # GET /interactive_models/1.xml
  def show
    @interactive_model = InteractiveModel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @interactive_model }
    end
  end

  # GET /interactive_models/new
  # GET /interactive_models/new.xml
  def new
    @interactive_model = InteractiveModel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @interactive_model }
    end
  end

  # GET /interactive_models/1/edit
  def edit
    @interactive_model = InteractiveModel.find(params[:id])
  end

  # POST /interactive_models
  # POST /interactive_models.xml
  def create
    @interactive_model = InteractiveModel.new(params[:interactive_model])

    respond_to do |format|
      if @interactive_model.save
        flash[:notice] = 'InteractiveModel was successfully created.'
        format.html { redirect_to(@interactive_model) }
        format.xml  { render :xml => @interactive_model, :status => :created, :location => @interactive_model }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @interactive_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /interactive_models/1
  # PUT /interactive_models/1.xml
  def update
    @interactive_model = InteractiveModel.find(params[:id])

    respond_to do |format|
      if @interactive_model.update_attributes(params[:interactive_model])
        flash[:notice] = 'InteractiveModel was successfully updated.'
        format.html { redirect_to(@interactive_model) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @interactive_model.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /interactive_models/1
  # DELETE /interactive_models/1.xml
  def destroy
    @interactive_model = InteractiveModel.find(params[:id])
    @interactive_model.destroy

    respond_to do |format|
      format.html { redirect_to(interactive_models_url) }
      format.xml  { head :ok }
    end
  end
end
