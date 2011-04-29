class Embeddable::VideoPlayersController < ApplicationController
  # GET /embeddable_video_players
  # GET /embeddable_video_players.xml
  def index    
    @video_players = Embeddable::VideoPlayer.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @embeddable_video_players}
    end
  end

  # GET /embeddable_video_players/1
  # GET /embeddable_video_players/1.xml
  def show
    @video_player = Embeddable::VideoPlayer.find(params[:id])
    if request.xhr?
      render :partial => 'show', :locals => { :video_player => @video_player }
    else
      respond_to do |format|
        format.html # show.html.haml
        format.otml   { render :layout => "layouts/embeddable/video_player" } # video_player.otml.haml
        format.jnlp   { render :partial => 'shared/show', :locals => { :runnable => @video_player, :teacher_mode => false } }

        format.config { render :partial => 'shared/show', :locals => { :runnable => @video_player, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
        format.dynamic_otml { render :partial => 'shared/show', :locals => {:runnable => @video_player, :teacher_mode => @teacher_mode } }
        format.xml    { render :video_player => @video_player }
      end
    end
  end

  # GET /embeddable_video_players/new
  # GET /embeddable_video_players/new.xml
  def new
    @video_player = Embeddable::VideoPlayer.new
    if request.xhr?
      render :partial => 'remote_form', :locals => { :video_player => @video_player }
    else
      respond_to do |format|
        format.html # renders new.html.haml
        format.xml  { render :xml => @video_player }
      end
    end
  end

  # GET /embeddable_video_players/1/edit
  def edit
    @video_player = Embeddable::VideoPlayer.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :video_player => @video_player }
    else
      respond_to do |format|
        format.html 
        format.xml  { render :xml => @video_player  }
      end
    end
  end
  

  # POST /embeddable_video_players
  # POST /embeddable_video_players.xml
  def create
    @video_player = Embeddable::VideoPlayer.new(params[:embeddable_video_player])
    cancel = params[:commit] == "Cancel"
    if request.xhr?
      if cancel 
        redirect_to :index
      elsif @video_player.save
        render :partial => 'new', :locals => { :video_player => @video_player }
      else
        render :xml => @video_player.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @video_player.save
          flash[:notice] = 'Embeddable::imagequestion was successfully created.'
          format.html { redirect_to(@video_player) }
          format.xml  { render :xml => @video_player, :status => :created, :location => @video_player }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @video_player.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /embeddable_video_players/1
  # PUT /embeddable_video_players/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @video_player = Embeddable::VideoPlayer.find(params[:id])
    if request.xhr?
      if cancel || @video_player.update_attributes(params[:embeddable_video_player])
        render :partial => 'show', :locals => { :video_player => @video_player }
      else
        render :xml => @video_player.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @video_player.update_attributes(params[:embeddable_video_player])
          flash[:notice] = 'Embeddable::imagequestion was successfully updated.'
          format.html { redirect_to(@video_player) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @video_player.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /embeddable_video_players/1
  # DELETE /embeddable_video_players/1.xml
  def destroy
    @video_player = Embeddable::VideoPlayer.find(params[:id])
    respond_to do |format|
      format.html { redirect_to(video_players_url) }
      format.xml  { head :ok }
      format.js
    end
    
    # TODO:  We should move this logic into the model!
    @video_player.page_elements.each do |pe|
      pe.destroy
    end
    @video_player.destroy    
  end
end
