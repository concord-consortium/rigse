class Import::ImportsController < ApplicationController

  # PUNDIT_CHECK_FILTERS
  before_action :admin_only

  def import_school_district_json
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    begin
      file_data = params[:import][:import].read

      json_data = JSON.parse file_data, :symbolize_names => true
      if json_data[:districts].nil? || json_data[:schools].nil?
        raise "Invalid JSON"
      end
    rescue => e
      redirect_to import_school_district_status_import_imports_path({:message => "Invalid JSON"})
      return
    end
    import = Import::Import.create!
    import.upload_data = file_data
    import.save!
    job = Import::ImportSchoolsAndDistricts.perform_later(import.id)
    import.update_attribute(:job_id, job.id)
    import.update_attribute(:import_type, Import::Import::IMPORT_TYPE_SCHOOL_DISTRICT)
    redirect_to :action => "import_school_district_status"
  end

  def import_user_json
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    begin
      file_data = params[:import][:import].read

      json_data = JSON.parse file_data, :symbolize_names => true
      if json_data[:users].nil?
        raise "Invalid JSON"
      end
    rescue => e
      redirect_to import_user_status_import_imports_path({:message => "Invalid JSON"})
      return
    end
    import = Import::Import.create!
    import.upload_data = file_data
    import.save!
    job = Import::ImportUsers.perform_later(import.id)
    import.update_attribute(:job_id, job.id)
    import.update_attribute(:import_type, Import::Import::IMPORT_TYPE_USER)
    redirect_to :action => "import_user_status"
  end

  def import_school_district_status
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    @import_type = Import::Import::IMPORT_TYPE_SCHOOL_DISTRICT
    imports_in_progress = Import::Import.in_progress(Import::Import::IMPORT_TYPE_SCHOOL_DISTRICT)
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
      render "import/imports/import_status"
    end
  end

  def import_user_status
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    @import_type = Import::Import::IMPORT_TYPE_USER
    imports_in_progress = Import::Import.in_progress(Import::Import::IMPORT_TYPE_USER)
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
      render "import/imports/import_status"
    end
  end

  def download
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    user_import = Import::Import.where(:import_type => Import::Import::IMPORT_TYPE_USER).last
    duplicate_users = Import::DuplicateUser.where(:import_id => user_import.id)
    if duplicate_users.length == 0
      flash['alert'] = "No duplicate users found in the import."
      redirect_back(fallback_location: admin_path)
    else
      send_data duplicate_users.to_json,
        :filename => "duplicate_users.json",
        :type => "application/json",
        :x_sendfile => true
    end
  end

  def import_activity_status
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    respond_to do |format|
      format.js { render :json => { :html => render_to_string('import_activity_status')}, :content_type => 'text/json' }
      format.html
    end
  end

  def import_activity
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    begin
      json_object = JSON.parse "#{params['import_activity_form'].read}", :symbolize_names => true
      req_url = "#{request.protocol}#{request.host_with_port}"
      auth_url = get_authoring_url
      import = Import::Import.create!()
      import.update_attribute(:import_type, Import::Import::IMPORT_TYPE_ACTIVITY)
      import.update_attribute(:user_id, current_visitor.id)
      job = Import::ImportExternalActivity.perform_later(import, json_object, req_url, auth_url, current_visitor.id)
      import.update_attribute(:job_id, job.id)
      redirect_to action: :import_activity_progress
    rescue => e
      render :json => {:error => "Import failed."}
    end
  end

  def import_activity_progress
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    if request.xhr?
      @import_activity = fetch_import_activity
      render :json => {:progress => @import_activity ? @import_activity.progress : @import_activity}
    end
  end

  def activity_clear_job
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    if request.xhr?
      import_activity = fetch_import_activity
      import_activity.destroy
    end
    head :ok
  end

  def batch_import_status
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    @import_type = Import::Import::IMPORT_TYPE_BATCH_ACTIVITY
    imports_in_progress = Import::Import.in_progress(Import::Import::IMPORT_TYPE_BATCH_ACTIVITY)
    @imports_progress = []
    imports_in_progress.each_with_index do |import_in_progress, index|
      import_success = import_in_progress.import_data.select{|item| item['success'] == true} if import_in_progress.import_data
      @imports_progress << {
        id: import_in_progress.id,
        progress: import_in_progress.progress,
        total: import_in_progress.total_imports,
        success: import_success ? import_success.size : 0
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
      render "import/imports/import_status"
    end
  end

  def batch_import_data
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    import = Import::Import.where(:import_type => Import::Import::IMPORT_TYPE_BATCH_ACTIVITY).last
    imports_succeed = import.import_data.select{|item| item['success'] == true}
    import_data = []
    import_data << {
      total_imports: import.total_imports,
      success: imports_succeed ? imports_succeed.size : 0
    }
    if request.xhr?
      render :json => {:data => import_data}
    end
  end

  def batch_import
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    begin
      json_object = JSON.parse "#{params['import']['import'].read}", :symbolize_names => true
      if json_object.class.name != "Array" || json_object.size < 1
        raise "Invalid JSON"
      end
    rescue => e
      redirect_to import_user_status_import_imports_path({:message => "Invalid JSON"})
      return
    end
    req_url = "#{request.protocol}#{request.host_with_port}"
    auth_url = get_authoring_url
    import = Import::Import.create!()
    import.update_attribute(:import_type,Import::Import::IMPORT_TYPE_BATCH_ACTIVITY)
    job = Import::ImportExternalActivity.perform_later(import, json_object, req_url, auth_url, current_visitor.id)
    import.update_attribute(:job_id,job.id)
    redirect_to :action => "batch_import_status"
  end

  def failed_batch_import
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHOOSE_AUTHORIZE
    # no authorization needed ...
    # authorize Import::Import
    # authorize @import
    # authorize Import::Import, :new_or_create?
    # authorize @import, :update_edit_or_destroy?
    batch_import = Import::Import.where(:import_type => Import::Import::IMPORT_TYPE_BATCH_ACTIVITY).last
    imports_failed = batch_import.import_data.select{|item| item["success"] == false}.map{|item| item.except("success")}
    if imports_failed
      send_data imports_failed.to_json,
        :filename => "failed_imports.json",
        :type => "application/json",
        :x_sendfile => true
    else
      flash['alert'] = "No failed imports."
      redirect_back(fallback_location: { action: "batch_import_status" })
    end
  end

  protected
  def admin_only
    unless current_visitor.has_role?('admin')
      raise Pundit::NotAuthorizedError
    end
  end
  def get_authoring_url
    auth_uri = URI.parse("#{APP_CONFIG[:authoring_site_url]}/import/import_portal_activity").to_s
    auth_uri.sub!(/\A\/\//,request.protocol)
    auth_uri
  end

  private

  def fetch_import_activity
    Import::Import
        .where(user_id: current_visitor.id,
               import_type: Import::Import::IMPORT_TYPE_ACTIVITY)
        .last
  end
end
