require 'fileutils'

class RinetData
  include RinetCsvFields  # definitions for the fields we use when parsing.
    
  @@districts = %w{07 16}
  @@csv_files = %w{students staff courses enrollments staff_assignments staff_sakai student_sakai}
  @@local_dir = "#{RAILS_ROOT}/rinet_data/districts/csv"

  def initialize
    @rinet_data_config = YAML.load_file("#{RAILS_ROOT}/config/rinet_data.yml")[RAILS_ENV].symbolize_keys
  end
  
  def get_csv_files
    @new_date_time_key = Time.now.strftime("%Y%m%d_%H%M%S")
    Net::SFTP.start(@rinet_data_config[:host], @rinet_data_config[:username] , :password => @rinet_data_config[:password]) do |sftp|
      @@districts.each do |district|
        local_district_path = "#{@@local_dir}/#{district}/#{@new_date_time_key}"
        FileUtils.mkdir_p(local_district_path)
        puts
        @@csv_files.each do |csv_file|
          # download a file or directory from the remote host
          remote_path = "#{district}/#{csv_file}.csv"
          local_path = "#{local_district_path}/#{csv_file}.csv"
          puts "downloading: #{remote_path} and saving to: \n  #{local_path}"
          sftp.download!(remote_path, local_path)
        end
        current_path = "#{@@local_dir}/#{district}/current"
        FileUtils.ln_s(local_district_path, current_path, :force => true)
      end
    end
    puts
  end

  def parse_csv_files(date_time_key='current')
    if @parsed_data
      @parsed_data
    else
      @parsed_data = []
      @@districts.each do |district|
        puts
        local_dir_path = "#{@@local_dir}/#{district}/#{date_time_key}"
        if File.exists?(local_dir_path)
          @@csv_files.each do |csv_file|
            local_path = "#{local_dir_path}/#{csv_file}.csv"
            data = FasterCSV.read(local_path)
            puts "parsing: #{data.length} rows from:\n  #{local_path}"
            @parsed_data << [ "#{district}_#{csv_file}", data ]
          end
        else
          puts "no data folder found: #{local_dir_path}"
        end
      end
    end
    puts
    @parsed_data
  end
  
  
end