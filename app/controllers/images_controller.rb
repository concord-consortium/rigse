class ImagesController < ApplicationController
  before_filter :teacher_required
  before_filter :find_image_and_verify_owner, :only => [:edit, :update, :destroy]
  # scale the text since most images will be displayed at around screen size

  # GET /images
  # GET /images.xml
  def index
    @only_mine = param_find(:only_mine, true)
    @name = param_find(:name)
    @sort_order = param_find(:sort_order, true)

    @images = Image.search_list({
      :name => @name,
      :only_current_users => @only_mine,
      :user => current_user,
      :sort_order => @sort_order,
      :paginate => true,
      :per_page => 36,
      :page => params[:page]
    })
    @paginated_objects = @images

    if request.xhr?
      render :partial => 'runnable_list', :locals => { :images => @images, :paginated_objects => @images }
      return
    end
  end

  # GET /images/1
  # GET /images/1.xml
  def show
    if current_user.has_role? 'admin'
      @image = Image.find(params[:id])
    else
      @image = Image.visible_to_user_with_drafts(current_user).find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/new
  # GET /images/new.xml
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.xml
  def create
    params[:image][:user_id] = current_user.id.to_s
    @image = Image.new(params[:image])

    respond_to do |format|
      if @image.save
        flash[:notice] = 'Image was successfully created.'
        format.html { redirect_to(@image) }
        format.xml  { render :xml => @image, :status => :created, :location => @image }
        format.js do
          responds_to_parent do
            render :update do |page|
              page.insert_html :bottom, "images", :partial => 'images/list_item', :object => @image
              page.visual_effect :highlight, "image_#{@image.id}" 
            end
          end
        end
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
        format.js do
          responds_to_parent do
            render :update do |page|
                # update the page with an error message
            end
          end
        end
      end
    end
  end

  # PUT /images/1
  # PUT /images/1.xml
  def update
    pars = params[:image]
    orig_path = @image.image.path(:original)
    img_pars = {:image => (pars.delete(:image) || (orig_path ? File.open(orig_path) : nil))}

    respond_to do |format|
      # we're updating the image separately, to avoid having stale attributions being attached to the image
      if @image.update_attributes(pars) && @image.reload && @image.update_attributes(img_pars)
        flash[:notice] = 'Image was successfully updated.'
        format.html { redirect_to(@image) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @image.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.xml
  def destroy
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
      format.xml  { head :ok }
    end
  end

  protected

  def teacher_required
    return true if logged_in? && (current_user.portal_teacher || current_user.has_role?("admin"))
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end

  def find_image_and_verify_owner
    @image = Image.find(params[:id])
    return if @image.changeable?(current_user)
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
end
