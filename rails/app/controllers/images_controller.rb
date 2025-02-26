class ImagesController < ApplicationController

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

  # get /view/1
  # for obtaining an image. (redirects to actual images path)
  def view
    # no authorization needed ...
    @image = Image.find(params[:id])
    redirect_to url_for(@image.image)
  end

  protected

  def find_image
    @image = Image.find(params[:id])
  end
end
