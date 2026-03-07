class Admin::OidcClientsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'OIDC client'})
  end

  public

  # GET /admin/oidc_clients
  def index
    authorize Admin::OidcClient
    @oidc_clients = Admin::OidcClient.all.paginate(per_page: 20, page: params[:page])
  end

  # GET /admin/oidc_clients/1
  def show
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
  end

  # GET /admin/oidc_clients/new
  def new
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.new
  end

  # GET /admin/oidc_clients/1/edit
  def edit
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
  end

  # POST /admin/oidc_clients
  def create
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.new(oidc_client_params)

    if @oidc_client.save
      flash['notice'] = 'OIDC client was successfully created.'
      redirect_to action: :index
    else
      render action: 'new'
    end
  end

  # PUT /admin/oidc_clients/1
  def update
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
    if @oidc_client.update(oidc_client_params)
      flash['notice'] = 'OIDC client was successfully updated.'
      redirect_to action: :index
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/oidc_clients/1
  def destroy
    authorize Admin::OidcClient
    @oidc_client = Admin::OidcClient.find(params[:id])
    @oidc_client.destroy
    flash['notice'] = 'OIDC client was successfully deleted.'
    redirect_to action: :index
  end

  private

  def oidc_client_params
    params.require(:admin_oidc_client).permit(:name, :sub, :email, :user_id, :active)
  end
end
