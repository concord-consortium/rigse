class Admin::TagsController < ApplicationController
  include RestrictedController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only

  # GET /admin_tags
  # GET /admin_tags.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Admin::Tag
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    @tags = policy_scope(Admin::Tag)
    @admin_tags = Admin::Tag.search(params[:search], params[:page], nil)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @admin_tags }
    end
  end

  # GET /admin_tags/1
  # GET /admin_tags/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @tag
    @admin_tag = Admin::Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @admin_tag }
    end
  end

  # GET /admin_tags/new
  # GET /admin_tags/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Admin::Tag
    @admin_tag = Admin::Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @admin_tag }
    end
  end

  # GET /admin_tags/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @tag
    @admin_tag = Admin::Tag.find(params[:id])

    if request.xhr?
      render :partial => 'remote_form', :locals => { :admin_tag => @admin_tag }
    end
  end

  # POST /admin_tags
  # POST /admin_tags.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    authorize Admin::Tag
    @admin_tag = Admin::Tag.new(params[:admin_tag])

    respond_to do |format|
      if @admin_tag.save
        format.html { redirect_to(@admin_tag, :notice => 'Admin::Tag was successfully created.') }
        format.xml  { render :xml => @admin_tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @admin_tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin_tags/1
  # PUT /admin_tags/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @tag
    @admin_tag = Admin::Tag.find(params[:id])

    if request.xhr?
      @admin_tag.update_attributes(params[:admin_tag])
      render :partial => 'show', :locals => { :admin_tag => @admin_tag }
    else
      respond_to do |format|
        if @admin_tag.update_attributes(params[:admin_tag])
          format.html { redirect_to(@admin_tag, :notice => 'Admin::Tag was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @admin_tag.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /admin_tags/1
  # DELETE /admin_tags/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    authorize @tag
    @admin_tag = Admin::Tag.find(params[:id])
    @admin_tag.destroy

    respond_to do |format|
      format.html { redirect_to(admin_tags_url) }
      format.xml  { head :ok }
    end
  end
end
