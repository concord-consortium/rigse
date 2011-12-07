module SisImporter
  class RemoteConfiguration < Configuration

    def defaults
      super.merge({
        :district_file_name => 'IMPORT',
        :remote_root_path   => 'district',
        :transport_class    => SisImporter::SftpFileTransport
      })
    end

    def pending_name
      self.district_file_name
    end

    def in_progress_name
      "#{self.pending_name}_IN_PROGRESS"
    end

    def success_name
      "#{self.pending_name}_SUCCESS"
    end

    def error_name
      "#{self.pending_name}_ERROR"
    end

    def districts
      if defined?(@districts)
        return @districts
      end
      fetch_districts
    end

    def signal_in_progress()
      change_signal(pending_name, in_progress_name)
    end

    def signal_success(data=nil)
      change_signal(in_progress_name,success_name,data)
    end

    def signal_failure(data=nil)
      change_signal(in_progress_name, error_name,data)
    end

    def copy_logs(log)
      upload_file(log.log_path)
      upload_file(log.report_path)
    end

    def in_progress?
      begin
        Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
          stat = sftp.stat!(File.join(self.remote_root_path,in_progress_name))
        end
      rescue Net::SFTP::StatusException => e
        return false
      end
      return true
    end

    def remove_old_signals
      [self.success_name,self.error_name].each do |file|
        begin
          remove_file(file)
        rescue
        end
      end
    end

    protected

    def district_list_path
      File.join(self.remote_root_path,district_file_name)
    end

    def local_tmp_path
      if defined?(@local_tmp_path)
        return @local_tmp_path
      end
      file = Tempfile.new(district_file_name)
      @local_tmp_path = file.path
      file.close
      @local_tmp_path
    end

    def fetch_districts
      begin
        Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
          sftp.download!(district_list_path, local_tmp_path)
          # parse data
          File.open(local_tmp_path, "r") do |file|
            convert_districts(file.readlines)
          end
        end
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{self.username}@#{self.host}", e)
      rescue RuntimeError => e
        # raise Errors::TransportError.new("Download Failed: #{self.host}/#{self.district_list_path} ==> #{self.local_tmp_path} (#{e.message})", e)
        # TODO we want a reference to the log here so we can log the
        # error.
        @districts=[]
      end
      @districts
    end

    def write_file(filename, data)
      begin
        Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
          sftp.file.open(File.join(self.remote_root_path,filename), "w") do |f|
            f.write(data)
          end
        end
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{self.username}@#{self.host}", e)
      rescue RuntimeError => e
        raise Errors::TransportError.new("Download Failed: #{self.host}/#{self.district_list_path} ==> #{self.local_tmp_path} (#{e.message})", e)
      end
    end

    def convert_districts(dists)
      @districts = dists.map { |d| convert_district_name (d) }.reject { |d| d.nil? || d.empty? }
    end

    def convert_district_name(district)
      district.strip
    end


    def remove_file(file)
      begin
        Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
          sftp.remove!(File.join(self.remote_root_path,file))
        end
      rescue Exception => e
        # self.log.warn("Unable to remove file: #{file} :#{$!}")
      end
    end

    def upload_file(file)
      remote = File.join(self.remote_root_path,File.basename(file))
      begin
        Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
          sftp.upload!(file,remote)
        end
      rescue Exception => e
        # self.log.warn("Unable to remove file: #{file} :#{$!}")
      end

    end

    def change_signal(from, to,data=nil)
      begin
        remove_file(from)
        write_file(to,data)
      rescue
        # self.log.warn("Unable to change signal: #{from} #{to} : #{$!}")
      end
    end

  end
end
