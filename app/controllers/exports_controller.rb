class ExportsController < ApplicationController

  before_filter :admin_only

  def index
    redirect_to :action => "export_status"
  end

  def generate_school_district_json
    last_export = Export.find(:last, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_SCHOOL_DISTRICT])
    if last_export.nil? || last_export.finished?
      export = Export.create!()
      job = Delayed::Job.enqueue GenerateSchoolDistrictJSON.new(export.id, current_user.id)
      export.update_attribute(:job_id, job.id)
      export.update_attribute(:export_type, Export::EXPORT_TYPE_SCHOOL_DISTRICT)
    end
    redirect_to :action => "export_school_district_status"
  end

  def generate_user_json
    last_export = Export.find(:last, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_USER])
    if last_export.nil? || last_export.finished?
      export = Export.create!()
      job = Delayed::Job.enqueue GenerateUserJSON.new(export.id, current_user.id)
      export.update_attribute(:job_id, job.id)
      export.update_attribute(:export_type, Export::EXPORT_TYPE_USER)
    end
    redirect_to :action => "export_user_status"
  end

  def export_school_district_status
    @export_list = Export.find(:all, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_SCHOOL_DISTRICT])
    @last_export = Export.find(:last, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_SCHOOL_DISTRICT])
    render "exports/export_status", :locals => {:export_type => Export::EXPORT_TYPE_SCHOOL_DISTRICT}
  end

  def export_user_status
    @export_list = Export.find(:all, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_USER])
    @last_export = Export.find(:last, :conditions => [ "export_type = ?", Export::EXPORT_TYPE_USER])
    render "exports/export_status", :locals => {:export_type => Export::EXPORT_TYPE_USER}
  end

  def download
    @export = Export.find(params[:id])
    filename = @export.export_type == Export::EXPORT_TYPE_USER ? "export_users.json" : "export_schools_and_districts.json"
    path_to_file = "#{Rails.root}/#{@export.file_path}"
    if File.exist?(path_to_file)
      data = File.read(path_to_file)
      send_data data,
        :filename => filename,
        :type => "application/json",
        :x_sendfile => true
    else
      flash[:error] = "File not exist."
      redirect_to(:back)
    end
  end

  def destroy
    @export = Export.find(params[:id])
    redirect_action = @export.export_type == Export::EXPORT_TYPE_USER ? "export_user_status" : "export_school_district_status"
    path_to_file = "#{Rails.root}/#{@export.file_path}"
    File.delete(path_to_file) if File.exist?(path_to_file)
    @export.destroy
    redirect_to :action => redirect_action
  end

  protected

  def admin_only
    unless current_user.has_role?('admin')
      flash[:notice] = "Please log in as an administrator" 
      redirect_to(:home)
    end
  end
end