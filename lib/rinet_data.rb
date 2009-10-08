require 'fileutils'

class RinetData

  @@districts = %w{07 16}
  @@csv_files = %w{students staff staff_sakai courses enrollments staff_assignments}
  @@local_dir = "#{RAILS_ROOT}/rinet_data/districts/csv"

  def initialize
    @rinet_data_config = YAML.load_file("#{RAILS_ROOT}/config/rinet_data_config.yml")[RAILS_ENV].symbolize_keys
  end

  def get_csv_files
    Net::SFTP.start(@rinet_data_config[:host], @rinet_data_config[:username] , :password => @rinet_data_config[:password]) do |sftp|
      @@districts.each do |district|
        FileUtils.mkdir_p(local_dir)
        @@csv_files.each do |csv_file|
          # download a file or directory from the remote host
          remote_path = "#{district}/#{csv_file}.csv"
          local_path = "#{@@local_dir}/#{district}/#{csv_file}.csv"
          puts "downloading: #{remote_path} and saving to: #{local_path}"
          sftp.download!(remote_path, local_path)
        end
      end
    end
  end

  def parse_csv_files
    if @parsed_data
      @parsed_data
    else
      @parsed_data = []
      @@districts.each do |district|
        @@csv_files.each do |csv_file|
          local_path = "#{@@local_dir}/#{district}/#{csv_file}.csv"
          data = FasterCSV.read(local_path)
          puts "parsing: #{local_path}: #{data.length} rows"
          @parsed_data << [ "#{district}_#{csv_file}", data ]
        end
      end
    end
    @parsed_data
  end

end