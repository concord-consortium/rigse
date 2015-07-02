class ImportsController < ApplicationController

  before_filter :admin_only

  def import_school_district_json
    file_data = params[:import][:import].read 
    begin
      json_data = JSON.parse file_data, :symbolize_names => true
      if json_data[:districts].nil? || json_data[:schools].nil?
        raise "Invalid JSON"
      end
    rescue => e
      redirect_to import_school_district_status_imports_path({:message => "Invalid JSON"})
      return
    end
    import = Import.create!()
    import.upload_data = file_data
    import.save!
    job = Delayed::Job.enqueue ImportSchoolsAndDistricts.new(import.id)
    import.update_attribute(:job_id, job.id)
    import.update_attribute(:import_type, Import::IMPORT_TYPE_SCHOOL_DISTRICT)
    redirect_to :action => "import_school_district_status"
  end

  def import_user_json
    file_data = params[:import][:import].read
    begin
      json_data = JSON.parse file_data, :symbolize_names => true
      if json_data[:users].nil?
        raise "Invalid JSON"
      end
    rescue => e
      redirect_to import_user_status_imports_path({:message => "Invalid JSON"})
      return
    end
    import = Import.create!()
    import.upload_data = file_data
    import.save!
    job = Delayed::Job.enqueue ImportUsers.new(import.id)
    import.update_attribute(:job_id, job.id)
    import.update_attribute(:import_type, Import::IMPORT_TYPE_USER)
    redirect_to :action => "import_user_status"
  end

  def import_school_district_status
    @import_type = Import::IMPORT_TYPE_SCHOOL_DISTRICT
    imports_in_progress = Import.in_progress(Import::IMPORT_TYPE_SCHOOL_DISTRICT)
    @imports_progress = []
    imports_in_progress.each_with_index do |import_in_progress, index|
      @imports_progress << {
        id: import_in_progress.id,        
        progress: import_in_progress.progress,
        total: import_in_progress.total_imports
      }
      import_in_progress.destroy if import_in_progress.progress == -1
    end
    if request.xhr?
      if params[:message]
        render :json => {:error => params[:message]}, :status => 500
      else
        render :json => {:progress => @imports_progress}
      end
    else
      render "imports/import_status"
    end
  end

  def import_user_status
    @import_type = Import::IMPORT_TYPE_USER
    @imports_in_progress = Import.in_progress(Import::IMPORT_TYPE_USER)
    imports_progress = []
    @imports_in_progress.each_with_index do |import_in_progress, index|
      imports_progress << {
        id: import_in_progress.id,        
        progress: import_in_progress.progress,
        total: import_in_progress.total_imports
      }
      import_in_progress.destroy if import_in_progress.progress == -1
    end
    if request.xhr?
      if params[:message]
        render :json => {:error => params[:message]}, :status => 500
      else
        render :json => {:progress => imports_progress}
      end
    else
      render "imports/import_status"
    end
  end

  def download
    import_id = Import.find(:last, :conditions => {:import_type => Import::IMPORT_TYPE_USER})
    duplicate_users = ImportDuplicateUser.find(:all, :conditions => {:import_id => import_id, :duplicate_by => ImportDuplicateUser::DUPLICATE_BY_LOGIN_AND_EMAIL})
    send_data duplicate_users.to_json,
      :filename => "duplicate_users.json",
      :type => "application/json",
      :x_sendfile => true
  end

  def import_activity_status
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import_activity_status')}, :content_type => 'text/json' }
      format.html
    end
  end

  def import_activity
    begin 
      json_object = JSON.parse "#{params['import_activity_form'].read}", :symbolize_names => true
      req_url = "#{request.protocol}#{request.host_with_port}"
      import = Import.create!()
      job = Delayed::Job.enqueue ImportExternalActivity.new(import,json_object,req_url,current_visitor.id)
      import.update_attribute(:job_id, job.id)
      import.update_attribute(:import_type, Import::IMPORT_TYPE_ACTIVITY)
      import.update_attribute(:user_id, current_visitor.id)
      redirect_to action: :import_activity_progress
    rescue => e
      render :json => {:error => "Import failed."}
    end
  end

  def import_activity_progress
    if request.xhr?
      @import_activity = Import.find_all_by_user_id_and_import_type(current_visitor.id,Import::IMPORT_TYPE_ACTIVITY).last
      render :json => {:progress => @import_activity ? @import_activity.progress : @import_activity}
    end
  end

  def activity_clear_job
    if request.xhr?
      import_activity = Import.find_all_by_user_id_and_import_type(current_visitor.id,Import::IMPORT_TYPE_ACTIVITY).last
      import_activity.destroy
    end
    render :nothing => true
  end

  protected
  def admin_only
    unless current_visitor.has_role?('admin')
      flash[:notice] = "Please log in as an administrator"
      redirect_to(:home)
    end
  end
end