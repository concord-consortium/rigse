
module SisImporter
  class LocalFileTransport < FileTransport

    def defaults
      super.merge({
        :remote_root => "district"
      })
    end

    def remote_root
      @configuration.remote_root
    end

    def remote_path(file)
      File.join(remote_root,file)
    end

    def remote_district_file(file)
      File.join(remote_path(district),file)
    end

    def copy(remote, local)
      begin
        FileUtils.cp(remote, local)
        log.info("copyed: #{remote} ==>  #{local}")
      rescue RuntimeError => e
        raise Errors::TransportError.new("copy Failed: #{remote} ==> #{local}", e)
      end
    end

    def get_csv_file(csv_filename)
      copy(remote_district_file(csv_filename),local_current_district_file(csv_filename))
    end

  end
end

