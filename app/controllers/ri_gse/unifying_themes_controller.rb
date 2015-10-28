class RiGse::UnifyingThemesController < ApplicationController
  # GET /RiGse/unifying_themes
  # GET /RiGse/unifying_themes.xml
  def index
    authorize RiGse::UnifyingTheme
    @unifying_themes = policy_scope(RiGse::UnifyingTheme)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @unifying_themes }
    end
  end

  # GET /RiGse/unifying_themes/1
  # GET /RiGse/unifying_themes/1.xml
  def show
    @unifying_theme = RiGse::UnifyingTheme.find(params[:id])
    authorize @unifying_theme

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @unifying_theme }
    end
  end

  # GET /RiGse/unifying_themes/new
  # GET /RiGse/unifying_themes/new.xml
  def new
    authorize RiGse::UnifyingTheme
    @unifying_theme = RiGse::UnifyingTheme.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @unifying_theme }
    end
  end

  # GET /RiGse/unifying_themes/1/edit
  def edit
    @unifying_theme = RiGse::UnifyingTheme.find(params[:id])
    authorize @unifying_theme
  end

  # POST /RiGse/unifying_themes
  # POST /RiGse/unifying_themes.xml
  def create
    authorize RiGse::UnifyingTheme
    @unifying_theme = RiGse::UnifyingTheme.new(params[:unifying_theme])

    respond_to do |format|
      if @unifying_theme.save
        flash[:notice] = 'RiGse::UnifyingTheme.was successfully created.'
        format.html { redirect_to(@unifying_theme) }
        format.xml  { render :xml => @unifying_theme, :status => :created, :location => @unifying_theme }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @unifying_theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /RiGse/unifying_themes/1
  # PUT /RiGse/unifying_themes/1.xml
  def update
    @unifying_theme = RiGse::UnifyingTheme.find(params[:id])
    authorize @unifying_theme

    respond_to do |format|
      if @unifying_theme.update_attributes(params[:unifying_theme])
        flash[:notice] = 'RiGse::UnifyingTheme.was successfully updated.'
        format.html { redirect_to(@unifying_theme) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @unifying_theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /RiGse/unifying_themes/1
  # DELETE /RiGse/unifying_themes/1.xml
  def destroy
    @unifying_theme = RiGse::UnifyingTheme.find(params[:id])
    authorize @unifying_theme
    @unifying_theme.destroy

    respond_to do |format|
      format.html { redirect_to(unifying_themes_url) }
      format.xml  { head :ok }
    end
  end
end
