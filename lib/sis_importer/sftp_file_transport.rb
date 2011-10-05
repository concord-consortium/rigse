
module SisImporter
  class SftpFileTransport < FileTransport
    
    attr_accessor :ssh_session
    attr_accessor :sftp_session

    def defaults
      super.merge({
        :host        => nil,
        :username    => nil,
        :password    => nil,
        :remote_root => "district"
      })
    end

    def remote_root
      @opts[:remote_root]
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
        sftp = Net::SFTP.start(@opts[:host], @opts[:username] , :password => @opts[:password])
        puts "Uploading: #{local} ==>  #{remote}"
        sftp.upload!(local, remote)
        logger.info("Uploaded: #{local} ==>  #{remote}")
        sftp.session.close
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{@opts[:username]}@#{@opts[:host]}", e)
      rescue RuntimeError => e
        raise Errors::TransportError.new("Download Failed: #{@opts[:host]}/#{remote} ==> #{local}", e)
      end
    end

    def download(remote, local)
      begin
        sftp = Net::SFTP.start(@opts[:host], @opts[:username] , :password => @opts[:password])
        sftp.download!(remote, local)
        logger.info("Downloaded: #{remote} ==>  #{local}")
        sftp.session.close
      rescue NoMethodError => e
        raise Errors::ConnectionError.new("Connection Failed: #{@opts[:username]}@#{@opts[:host]}", e)
      rescue RuntimeError => e
        raise Errors::TransportError.new("Download Failed: #{@opts[:host]}/#{remote} ==> #{local}", e)
      end
    end

    def get_csv_file(csv_filename)
      download(remote_district_file(filename),local_current_district_file(filename))
    end

    
    def send_report(filename)
      upload(local_current_report_file(filename), remote_district_report_file(filename))
    end

  end
end

