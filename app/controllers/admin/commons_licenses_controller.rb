class Admin::CommonsLicensesController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'license'})
  end

  public

  def index
    authorize CommonsLicense
    @licenses = CommonsLicense.find(:all).paginate(:per_page => 20, :page => params[:page])
  end

  def show
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
  end

  def new
    authorize CommonsLicense
    @license = CommonsLicense.new
  end

  def edit
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :license => @license }
    end
  end

  def create
    authorize CommonsLicense
    @license = CommonsLicense.new(params[:commons_license])

    if @license.save
      flash[:notice]='License was successfully created.'
      redirect_to action: :index
    else
      render :action => 'new'
    end
  end

  def update
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
    if request.xhr?
      if @license.update_attributes(params[:commons_license])
        render :partial => 'show', :locals => { :license => @license }
      else
        render :partial => 'remote_form', :locals => { :license => @license }, :status => 400
      end
    else
      if @license.update_attributes(params[:commons_license])
        flash[:notice]= 'License was successfully updated.'
        redirect_to action: :index
      else
        render :action => 'edit'
      end
    end
  end

  def destroy
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
    @license.destroy
    flash[:notice]= 'License was successfully deleted.'
    redirect_to action: :index
  end

end
