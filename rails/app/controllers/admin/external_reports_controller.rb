class Admin::ExternalReportsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'external report'})
  end

  public

  # GET /admin/reports
  def index
    authorize ExternalReport
    @reports = ExternalReport.all.paginate(:per_page => 20, :page => params[:page])
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
  end

  # POST /admin/report
  def create
    authorize ExternalReport
    @report = ExternalReport.new(external_report_strong_params(params[:external_report]))

    if @report.save
      flash['notice']='ExternalReport was successfully created.'
      redirect_to action: :index
    else
      render :action => 'new'
    end
  end

  # PUT /admin/report/1
  def update
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
    new_params = params[:external_report]
    saved_successfully = @report.update_attributes(external_report_strong_params(new_params))
    if saved_successfully && new_params[:default_report_for_source_type] != nil
      # Automatically ensure that only one report is selected as a default one for a given source type.
      ExternalReport
        .where('id != ? AND default_report_for_source_type = ?', @report.id, new_params[:default_report_for_source_type])
        .update_all(default_report_for_source_type: nil)
    end
    if saved_successfully
      flash['notice']= 'ExternalReport was successfully updated.'
      redirect_to action: :index
    else
      render :action => 'edit'
    end
  end

  # DELETE /admin/report/1
  def destroy
    authorize ExternalReport
    @report = ExternalReport.find(params[:id])
    @report.destroy
    flash['notice']= 'ExternalReport was successfully deleted.'
    redirect_to action: :index
  end

  def external_report_strong_params(params)
    params && params.permit(:allowed_for_students, :client, :client_id, :default_report_for_source_type,
                            :individual_activity_reportable, :individual_student_reportable, :launch_text,
                            :move_students_api_token, :move_students_api_url, :name, :report_type, :url, :use_query_jwt)
  end
end
