class ExportsController < ApplicationController
  
  before_filter :admin_only

  def index
    redirect_to :action => "export_status"
  end

  def generate_school_district_json
    last_export = Export.last
    if last_export.nil? || last_export.finished?
      export = Export.create!()
      job = Delayed::Job.enqueue GenerateJSON.new(export.id, current_user.id)
      export.update_attribute(:job_id, job.id)
    end
    redirect_to :action => "export_status"
  end

  def export_status
    @export_list = Export.all
    @last_export = Export.last
  end

  def download
    @export = Export.find(params[:id])
    send_data File.read("#{Rails.root}/#{@export.file_path}"),
      :filename => "export_schools_and_districts.json",
      :type => "application/json",
      :x_sendfile => true
  end

  def destroy
    @export = Export.find(params[:id])
    File.delete("#{Rails.root}/#{@export.file_path}")
    @export.destroy
    redirect_to :action => "export_status"
  end

  protected

  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
end