class Admin::TagsController < ApplicationController
  include RestrictedController
  before_filter :admin_only

  # GET /admin_tags
  # GET /admin_tags.xml
  def index
    @admin_tags = Admin::Tag.search(params[:search], params[:page], nil)
    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @admin_tags }
    end
  end

  # GET /admin_tags/1
  # GET /admin_tags/1.xml
  def show
    @admin_tag = Admin::Tag.find(params[:id])
    respond_to do |format|
      format.html # show.html.haml
      format.xml  { render :xml => @admin_tag }
    end
  end

  # GET /admin_tags/new
  def new
    @admin_tag = Admin::Tag.new
    # render new.html.haml
  end

  # GET /admin_tags/1/edit
  def edit
    @admin_tag = Admin::Tag.find(params[:id])
    # render edit.html.haml
  end

  # POST /admin_tags
  def create
    @admin_tag = Admin::Tag.new(params[:admin_tag])
    if @admin_tag.save
      redirect_to @admin_tag, notice: 'Admin::Tag was successfully created.'
    else
      render action: 'new'
    end
  end

  # PUT /admin_tags/1
  def update
    @admin_tag = Admin::Tag.find(params[:id])
    if @admin_tag.update_attributes(params[:admin_tag])
      redirect_to @admin_tag, notice: 'Admin::Tag was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin_tags/1
  def destroy
    @admin_tag = Admin::Tag.find(params[:id])
    @admin_tag.destroy
    redirect_to admin_tags_url, notice: "Tag #{@admin_tag.name} was deleted"
  end
end
