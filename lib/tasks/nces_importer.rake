require 'open-uri'

namespace :rigse do
  namespace :setup do
    
    nces_dir = File.join(%w{config rigse_data nces})
    school_layout_file = File.join(nces_dir, 'psu061blay.txt')
    district_layout_file = File.join(nces_dir, 'pau061blay.txt')
    
    desc 'Download nces data files from NCES websites'
    
    task :download_nces_data do
      orig_dir = Dir.pwd
      Dir.chdir(nces_dir)
      files = [
        'http://nces.ed.gov/ccd/data/zip/sc061bai_dat.zip',
        'http://nces.ed.gov/ccd/data/zip/sc061bkn_dat.zip',
        'http://nces.ed.gov/ccd/data/zip/sc061bow_dat.zip',
        'http://nces.ed.gov/ccd/pdf/psu061bgen.pdf',
        'http://nces.ed.gov/ccd/data/txt/psu061blay.txt',
        'http://nces.ed.gov/ccd/data/zip/ag061b_dat.zip',
        'http://nces.ed.gov/ccd/pdf/pau061bgen.pdf',
        'http://nces.ed.gov/ccd/data/txt/pau061blay.txt'
      ]
      files.each do |url_str|
        cmd = "wget -q -nc #{url_str}"
        puts cmd
        system(cmd)
        if url_str =~ /\.zip\z/
          cmd = "unzip -o #{File.basename(url_str)}"
          puts cmd
          system(cmd)
        end 
      end
      Dir.chdir(orig_dir)
    end
    
    desc 'Generate migration files for nces tables'
    task :generate_nces_migration => :environment do
      parser = NcesParser.new(district_layout_file, school_layout_file, 2006)
      parser.create_migration
    end
    
    desc 'Import nces data from file config/rigse_data/nces/*'
    task :import_nces_from_file => :environment do
      district_data_fnames = %w{ag061b.dat}
      district_data_fpaths = district_data_fnames.collect { |f| File.join(nces_dir, f) }
      school_data_fnames = %w{Sc061bai.dat Sc061bkn.dat Sc061bow.dat}
      school_data_fpaths = school_data_fnames.collect { |f| File.join(nces_dir, f) }
        
      parser = NcesParser.new(district_layout_file, school_layout_file, 2006)
      parser.load_db(district_data_fpaths, school_data_fpaths)
    end
    
  end
end
