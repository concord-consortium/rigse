class Admin::CommonsLicensesController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'license'})
  end

  public

  def index
    authorize CommonsLicense
    @licenses = CommonsLicense.all.paginate(:per_page => 20, :page => params[:page])
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
  end

  def create
    authorize CommonsLicense
    @license = CommonsLicense.new(commons_license_strong_params(params[:commons_license]))

    if @license.save
      flash['notice']='License was successfully created.'
      redirect_to action: :index
    else
      render :action => 'new'
    end
  end

  def update
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
    if @license.update(commons_license_strong_params(params[:commons_license]))
      flash['notice']= 'License was successfully updated.'
      redirect_to action: :index
    else
      render :action => 'edit'
    end
  end

  def destroy
    authorize CommonsLicense
    @license = CommonsLicense.find(params[:code])
    @license.destroy
    flash['notice']= 'License was successfully deleted.'
    redirect_to action: :index
  end

  def commons_license_strong_params(params)
    params && params.permit(:code, :deed, :description, :image, :legal, :name, :number)
  end
end
