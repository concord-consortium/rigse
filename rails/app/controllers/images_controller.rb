class ImagesController < ApplicationController
  before_action :find_image, :only => [:edit, :update, :destroy]
  # scale the text since most images will be displayed at around screen size

  protected

  def not_authorized_error_message
    super({resource_type: 'image'})
  end

  public

  # GET /images
  # GET /images.xml
  def index
    authorize Image
    @only_mine = param_find(:only_mine, true)
    @name = param_find(:name)
    @sort_order = param_find(:sort_order, true)

    @images = Image.search_list({
      :name => @name,
      :only_current_users => @only_mine,
      :user => current_visitor,
      :sort_order => @sort_order,
      :paginate => true,
      :per_page => 36,
      :page => params[:page]
    })
    @paginated_objects = @images
    # this will render index.html.haml by default
  end

  # GET /images/1
  # GET /images/1.xml
  def show
    if current_visitor.has_role? 'admin'
      @image = Image.find(params[:id])
    else
      @image = Image.visible_to_user_with_drafts(current_visitor).find(params[:id])
    end
    authorize @image

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/new
  # GET /images/new.xml
  def new
    authorize Image
    @image = Image.new
    # renders new.html.haml
  end

  # GET /images/1/edit
  def edit
    authorize @image
  end

  # POST /images
  def create
    authorize Image
    params[:image][:user_id] = current_visitor.id.to_s
    @image = Image.new(image_strong_params(params[:image]))

    if @image.save
      flash['notice'] = 'Image was successfully created.'
      redirect_to @image
    else
      flash['error'] = 'There was a problem with your submission. Check what you entered and try again.'
      render action: 'new'
    end
  end

  # PUT /images/1
  def update
    authorize @image
    if update_image_attributes
      flash['notice'] = 'Image was successfully updated.'
      redirect_to @image
    else
      flash['error'] = 'There was a problem with your submission. Check what you entered and try again.'
      render action: 'edit'
    end
  end

  # DELETE /images/1
  # DELETE /images/1.xml
  def destroy
    authorize @image
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
      format.xml  { head :ok }
    end
  end

  # get /view/1
  # for obtaining an image. (redirects to actual images path)
  def view
    # no authorization needed ...
    @image = Image.find(params[:id])
    redirect_to @image.image.url(:attributed)
  end

  protected

  def update_image_attributes
    my_params  = params[:image]
    return unless my_params
    image      = my_params.delete(:image)
    img_params = {:image => image}
    # we're updating the image separately, to avoid having
    # stale attributions being attached to the image
    if @image.update(image_strong_params(my_params))
      if @image.reload
        if image
          return @image.update(img_params)
        else
          return true
        end
      end
    end
    return false
  end

  def find_image
    @image = Image.find(params[:id])
  end

  def image_strong_params(params)
    params && params.permit(:attribution, :height, :image_content_type, :image_file_name, :image_file_size, :image_updated_at,
                            :license_code, :name, :publication_status, :user_id, :width)
  end
end
