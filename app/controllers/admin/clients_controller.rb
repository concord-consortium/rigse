class Admin::ClientsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'client'})
  end

  public

  # GET /admin/clients
  def index
    authorize Client
    @clients = Client.find(:all).paginate(:per_page => 20, :page => params[:page])
  end

  # GET /admin/client/1
  def show
    authorize Client
    @client = Client.find(params[:id])
  end

  # GET /admin/client/new
  def new
    authorize Client
    @client = Client.new
    @client.app_secret ||= SecureRandom.uuid()
  end

  # GET /admin/client/1/edit
  def edit
    authorize Client
    @client = Client.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :project => @client }
    end
  end

  # POST /admin/client
  def create
    authorize Client
    @client = Client.new(params[:client])

    if @client.save
      flash[:notice]='Client was successfully created.'
      redirect_to action: :index
    else
      render :action => 'new'
    end
  end

  # PUT /admin/client/1
  def update
    authorize Client
    @client = Client.find(params[:id])
    if request.xhr?
      if @client.update_attributes(params[:client])
        render :partial => 'show', :locals => { :project => @client }
      else
        render :partial => 'remote_form', :locals => { :project => @client }, :status => 400
      end
    else
      if @client.update_attributes(params[:client])
        flash[:notice]= 'Client was successfully updated.'
        redirect_to action: :index
      else
        render :action => 'edit'
      end
    end
  end

  # DELETE /admin/client/1
  def destroy
    authorize Client
    @client = Client.find(params[:id])
    @client.destroy
    flash[:notice]= 'Client was successfully deleted.'
    redirect_to action: :index
  end

end
