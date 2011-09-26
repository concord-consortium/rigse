module Embeddable::CommonActions
  # this requires some methods to called after inclusion
  # model_class
  # variable_name
  # display_name
  module ClassMethods
    def model_class
      @model_class ||= self.name.sub('sController', '').constantize
    end
    def variable_name
      # note: something similar to this is done ApplicationController#render_partial_for
      # this approach hasn't been used yet for a namespaced embeddables like biologica, so it might need
      # to be tweaked
      @variable_name ||= self.name.delete_module.sub('sController', '').underscore_module
    end
    def display_name(*args)
      return @display_name if args.empty?
      @display_name = args[0]
    end
  end
  def self.included(base)
    base.extend(ClassMethods)
  end
  def variable_name
    self.class.variable_name
  end
  def model_class
    self.class.model_class
  end
  def display_name
    self.class.display_name
  end
  def collection_instance=(value)
    # this could be computed 
    instance_variable_set("@#{variable_name.pluralize}", value)
  end
  def collection_instance
    instance_variable_get("@#{variable_name.pluralize}")
  end
  def single_instance=(value)
    instance_variable_set("@#{variable_name}", value)
  end
  def single_instance
    instance_variable_get("@#{variable_name}")
  end
  
  # GET /Embeddable/n_logo_models
  # GET /Embeddable/n_logo_models.xml
  def index
    self.collection_instance = model_class.search(params[:search], params[:page], nil)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => collection_instance}
    end
  end

  # GET /Embeddable/n_logo_models/1
  # GET /Embeddable/n_logo_models/1.xml
  def show
    self.single_instance =  model_class.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { variable_name.to_sym => single_instance }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml { render :layout => "layouts/embeddable/#{variable_name}" } # n_logo_model.otml.haml
        format.jnlp { render :partial => 'shared/show', :locals => { :runnable => single_instance , :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => single_instance, :session_id => (params[:session] || request.env["rack.session.options"][:id]) , :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => single_instance, :teacher_mode => @teacher_mode} }
        format.xml  { render :xml => single_instance }
      end
    end
  end

  # GET /Embeddable/n_logo_models/new
  # GET /Embeddable/n_logo_models/new.xml
  def new
    self.single_instance = model_class.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { variable_name.to_sym => single_instance }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => single_instance }
      end
    end
  end

  # GET /Embeddable/n_logo_models/1/edit
  def edit
    self.single_instance = model_class.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { variable_name.to_sym => single_instance }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => single_instance  }
      end
    end
  end
  

  # POST /Embeddable/n_logo_models
  # POST /Embeddable/n_logo_models.xml
  def create
    self.single_instance = model_class.new(params[variable_name.to_sym])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif single_instance.save
        render :partial => 'new', :locals => { variable_name.to_sym => single_instance }
      else
        render :xml => single_instance.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if single_instance.save
          flash[:notice] = "#{display_name} was successfully created."
          format.html { redirect_to(single_instance) }
          format.xml  { render :xml => single_instance, :status => :created, :location => single_instance }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => single_instance.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /Embeddable/n_logo_models/1
  # PUT /Embeddable/n_logo_models/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    self.single_instance = model_class.find(params[:id])
    if request.xhr?
      if cancel || single_instance.update_attributes(params["embeddable_#{variable_name}".to_sym])
        render :partial => 'show', :locals => { variable_name.to_sym => single_instance }
      else
        render :xml => single_instance.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if single_instance.update_attributes(params["embeddable_#{variable_name}".to_sym])
          flash[:notice] = "#{display_name} was successfully updated."
          format.html { redirect_to(single_instance) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => single_instance.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /Embeddable/n_logo_models/1
  # DELETE /Embeddable/n_logo_models/1.xml
  def destroy
    self.single_instance = model_class.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(send("#{variable_name}_url".to_sym)) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    single_instance.page_elements.each do |pe|
      pe.destroy
    end
    single_instance.destroy    
  end
end
