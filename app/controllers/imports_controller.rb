class ImportsController < ApplicationController

  before_filter :admin_only

  def import_school_district_json
    
    file_data = params[:import][:import].read 
    #begin
      json_data = JSON.parse file_data, :symbolize_names => true
    #rescue => e
      #flash[:warning] = "Invalid JSON"
      #redirect_to :action => "import_school_district_status"
    #end  
    name = "upload_#{UUIDTools::UUID.timestamp_create.hexdigest}.json"
    directory = "public/json"
    path = File.join(directory, name)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, "w") do |f|
      f.write(params[:import][:import].read)
    end    
    import = Import.create!()
    job = Delayed::Job.enqueue ImportSchoolsAndDistricts.new(import, path)
    import.update_attribute(:job_id, job.id)
    import.update_attribute(:import_type, Import::IMPORT_TYPE_SCHOOL_DISTRICT)
    redirect_to :action => "import_school_district_status"
  end

  def import_user_json
    name = "upload_#{UUIDTools::UUID.timestamp_create.hexdigest}.json"
    directory = "public/json"
    path = File.join(directory, name)
    dir = File.dirname(path)
    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    File.open(path, "w") do |f|
      f.write(params[:import][:import].read)
    end
    import = Import.create!()
    job = Delayed::Job.enqueue ImportUsers.new(import, path)
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
    end
    if request.xhr?
      render :json => {:progress => @imports_progress}
    else
      render "imports/import_status"
    end
  end

  def import_user_status
    @import_type = Import::IMPORT_TYPE_USER
    imports_in_progress = Import.in_progress(Import::IMPORT_TYPE_USER)
    @imports_progress = []
    imports_in_progress.each_with_index do |import_in_progress, index|
      @imports_progress << {
        id: import_in_progress.id,        
        a: import_in_progress.progress,
        b: import_in_progress.total_imports
      }
    end
    if request.xhr?
      render :json => {:progress => @imports_progress}
    else
      render "imports/import_status"
    end
  end

  protected
  def admin_only
    unless current_visitor.has_role?('admin')
      flash[:notice] = "Please log in as an administrator"
      redirect_to(:home)
    end
  end
end