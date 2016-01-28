class Admin::ExternalReportsController < ApplicationController

  rescue_from Pundit::NotAuthorizedError, with: :pundit_user_not_authorized

  private
  def pundit_user_not_authorized(exception)
    flash[:notice] = "Please log in as an administrator"
    redirect_to(:home)
  end

  public

  # GET /admin/reports
  def index
    authorize ExternalReport
    @reports = ExternalReport.find(:all).paginate(:per_page => 20, :page => params[:page])
  end

  # GET /admin/report/1
  def show
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
  end

  # GET /admin/report/new
  def new
    authorize ExternalReport
    @report = ExternalReport.new
  end

  # GET /admin/report/1/edit
  def edit
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :project => @report }
    end
  end

  # POST /admin/report
  def create
    authorize ExternalReport
    @report = ExternalReport.new(params[:external_report])

    if @report.save
      flash[:notice]='ExternalReport was successfully created.'
      redirect_to action: :index
    else
      render :action => 'new'
    end
  end

  # PUT /admin/report/1
  def update
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
    if request.xhr?
      if @report.update_attributes(params[:external_report])
        render :partial => 'show', :locals => { :project => @report }
      else
        render :partial => 'remote_form', :locals => { :project => @report }, :status => 400
      end
    else
      if @report.update_attributes(params[:external_report])
        flash[:notice]= 'ExternalReport was successfully updated.'
        redirect_to action: :index
      else
        render :action => 'edit'
      end
    end
  end

  # DELETE /admin/report/1
  def destroy
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
    @report.destroy
    flash[:notice]= 'ExternalReport was successfully deleted.'
    redirect_to action: :index
  end

end
