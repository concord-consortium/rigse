class Embeddable::SoundGraphersController < ApplicationController
  # GET /embeddable_sound_graphers
  # GET /embeddable_sound_graphers.xml
  def index    
    @sound_graphers  = Embeddable::SoundGrapher.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sound_graphers}
    end
  end

  # GET /embeddable_sound_graphers/1
  # GET /embeddable_sound_graphers/1.xml
  def show
    @sound_grapher = Embeddable::SoundGrapher.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :sound_grapher => @sound_grapher }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml   { render :layout => "layouts/embeddable/sound_grapher" } # sound_grapher.otml.haml
        format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @sound_grapher, :teacher_mode => false } }
        format.config { render :partial => 'shared/show', :locals => { :runnable => @sound_grapher, :session_id => (params[:session] || request.env["rack.session.options"][:id]), :teacher_mode => false } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @sound_grapher, :teacher_mode => @teacher_mode} }
        format.xml    { render :sound_grapher => @sound_grapher }
      end
    end
  end

  # GET /embeddable_sound_graphers/new
  # GET /embeddable_sound_graphers/new.xml
  def new
    @sound_grapher = Embeddable::SoundGrapher.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :sound_grapher => @sound_grapher }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @sound_grapher }
      end
    end
  end

  # GET /embeddable_sound_graphers/1/edit
  def edit
    @sound_grapher = Embeddable::SoundGrapher.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :sound_grapher => @sound_grapher }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @sound_grapher  }
      end
    end
  end
  

  # POST /embeddable_sound_graphers
  # POST /embeddable_sound_graphers.xml
  def create
    @sound_grapher = Embeddable::SoundGrapher.new(params[:embeddable_sound_grapher])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @sound_grapher.save
        render :partial => 'new', :locals => { :sound_grapher => @sound_grapher }
      else
        render :xml => @sound_grapher.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @sound_grapher.save
          flash[:notice] = "#{@sound_grapher.class.display_name} was successfully created."
          format.html { redirect_to(@sound_grapher) }
          format.xml  { render :xml => @sound_grapher, :status => :created, :location => @sound_grapher }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @sound_grapher.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /embeddable_sound_graphers/1
  # PUT /embeddable_sound_graphers/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @sound_grapher = Embeddable::SoundGrapher.find(params[:id])
    if request.xhr?
      if cancel || @sound_grapher.update_attributes(params[:embeddable_sound_grapher])
        render :partial => 'show', :locals => { :sound_grapher => @sound_grapher }
      else
        render :xml => @sound_grapher.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @sound_grapher.update_attributes(params[:embeddable_sound_grapher])
          flash[:notice] = "#{@sound_grapher.class.display_name} was successfully updated."
          format.html { redirect_to(@sound_grapher) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @sound_grapher.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /embeddable_sound_graphers/1
  # DELETE /embeddable_sound_graphers/1.xml
  def destroy
    @sound_grapher = Embeddable::SoundGrapher.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(sound_graphers_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @sound_grapher.page_elements.each do |pe|
      pe.destroy
    end
    @sound_grapher.destroy    
  end
end
