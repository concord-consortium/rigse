
module SisImporter
  class SftpFileTransport < FileTransport
    
    def remote_root
      self.configuration.remote_root || "district"
    end

    def remote_path(file)
      File.join(remote_root,file)
    end

    def remote_district_file(file)
      File.join(remote_path(district),file)
    end

    def remote_district_report_file(filename)
      timestamp_filename = "#{timestamp}_#{filename}"
      File.join(remote_path(district),timestamp_filename)
    end

    def upload(local, remote)
      begin
        sftp = Net::SFTP.start(self.configuration.host, self.configuration.username, :password => self.configuration.password)
        sftp.upload!(local, remote)
        log.info("Uploaded: #{local} ==>  #{remote}")
        sftp.session.close
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{self.configuration.user}@#{self.configuration.host}", e)
      rescue RuntimeError => e
        raise Errors::TransportError.new("Download Failed: #{self.configuration.host}/#{remote} ==> #{local}", e)
      end
    end

    def download(remote, local)
      begin
        sftp = Net::SFTP.start(self.configuration.host, self.configuration.username , :password => self.configuration.password)
        sftp.download!(remote, local)
        log.info("Downloaded: #{remote} ==>  #{local}")
        sftp.session.close
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{self.configuration.username}@#{self.configuration.host}", e)
      rescue RuntimeError => e
        raise Errors::TransportError.new("Download Failed: #{self.configuration.host}/#{remote} ==> #{local}", e)
      end
    end

    def get_csv_file(csv_filename)
      download(remote_district_file(csv_filename),local_current_district_file(csv_filename))
    end

    
    def send_report(filename)
      upload(local_current_report_file(filename), remote_district_report_file(filename))
    end

  end
end

