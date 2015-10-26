class ImagesController < ApplicationController
  # PUNDIT_CHECK_FILTERS
  before_filter :author_required, :except => :view
  before_filter :find_image_and_verify_owner, :only => [:edit, :update, :destroy]
  # scale the text since most images will be displayed at around screen size

  # GET /images
  # GET /images.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Image
    @only_mine = param_find(:only_mine, true)
    @name = param_find(:name)
    @sort_order = param_find(:sort_order, true)

    @images = Image.search_list({
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (found instance)
    @images = policy_scope(Image)
      :name => @name,
      :only_current_users => @only_mine,
      :user => current_visitor,
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
    if current_visitor.has_role? 'admin'
      @image = Image.find(params[:id])
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (found instance)
    authorize @image
    else
      @image = Image.visible_to_user_with_drafts(current_visitor).find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/new
  # GET /images/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Image
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @image }
    end
  end

  # GET /images/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @image
  end

  # POST /images
  # POST /images.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Image
    params[:image][:user_id] = current_visitor.id.to_s
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @image
    respond_to do |format|
      if update_image_attributes
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
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
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Image
    # authorize @image
    # authorize Image, :new_or_create?
    # authorize @image, :update_edit_or_destroy?
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
    if @image.update_attributes(my_params)
      if @image.reload
        if image
          return @image.update_attributes(img_params)
        else
          return true
        end
      end
    end
    return false
  end

  def teacher_required
    return true if logged_in? && (current_visitor.portal_teacher || current_visitor.has_role?("admin"))
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end

  def author_required
    return true if logged_in? && (current_visitor.has_role?("author"))
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end

  def find_image_and_verify_owner
    @image = Image.find(params[:id])
    return if @image.changeable?(current_visitor)
    flash[:error] = "You're not authorized to do this"
    redirect_to :home
  end
end
