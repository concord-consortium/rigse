module SisImporter
  class RemoteConfiguration < Configuration

    def districts
      if defined?(@districts)
        return @districts
      end
      fetch_districts
    end


    protected
    def district_list_path
      return "IMPORT"
    end

    def local_tmp_path
      if defined?(@local_tmp_path)
        return @local_tmp_path
      end
      file = Tempfile.new('IMPORT')
      @local_tmp_path = file.path
      file.close
      @local_tmp_path
    end

    def fetch_districts
      Net::SFTP.start(self.host, self.username, :password => self.password) do |sftp|
        sftp.download!(district_list_path, local_tmp_path)
      end  

      # parse data
      File.open(local_tmp_path, "r") do |file|
        convert_districts(file.readlines)
      end
    end

    def convert_districts(dists)
      @districts = dists.map { |d| convert_district_name (d) }.reject { |d| d.nil? || d.empty? }
    end

    def convert_district_name(district)
      district.downcase.strip
    end
  end
end
