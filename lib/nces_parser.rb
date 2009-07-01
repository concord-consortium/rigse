require 'rails_generator'
require 'rails_generator/scripts/generate'

class NcesParser
  
  def initialize(district_layout_file, school_layout_file, year)
    ## @year_str gets inserted to the db table names
    @year_str = year.to_s[-2..-1]
    
    puts 'Parsing layout files ...'
    ## layouts are an array of arrays
    ## [ [c1, s1, e1, t1], [c2, s2, e2, t2], ...] where
    ## cn: column code (e.g. NCESSCH)
    ## sn: start pos
    ## en: end pos
    ## tn: data type
    @district_layout = _get_layout(district_layout_file)
    puts "#{@district_layout.size} variables retrieved from #{district_layout_file}"
    @school_layout = _get_layout(school_layout_file)
    puts "#{@school_layout.size} variables retrieved from #{school_layout_file}"
    
    @district_model = Kernel.const_get("Nces#{@year_str}District")
    @school_model = Kernel.const_get("Nces#{@year_str}School")
  end
  
  def create_migration
    migration = NcesMigrationGenerator.new(@district_layout, @school_layout, @year_str)
    migration.write
  end
  
  def load_db(district_data_files, school_data_files)
    ## Delete all the entries first
    @district_model.delete_all
    @school_model.delete_all
    
    print 'Loading district data '
    district_data_files.each do |fpath|
      open(fpath) do |file|
        _parse_file(file, @district_layout, @district_model)
      end
    end
    
    print 'Loading school data '
    school_data_files.each do |fpath|
      open(fpath) do |file|
        _parse_file(file, @school_layout, @school_model)
      end
    end
  end
  
private

  def _get_layout(layout_file)
    columns = []
    open(layout_file) do |file|
      cnt = 0
      line = ''
      while (line = file.gets) && cnt < 2 do #fast forward until real data begins
        cnt += 1 if line =~ /=====/
      end
      while line do
        unless line =~ /\A\s/
          columns << _parse_column_def_line(line.strip)
        end
        line = file.gets
      end
    end
    columns
  end
  
  def _parse_column_def_line(line)
    tokens = line.split(/\s+/)
    ## Strip '+' prefix and year label suffix
    tokens[0] = tokens[0].sub(/\+?(.+?)([0-9]{2})?\z/, '\1')
    ## column 0: variable name
    ## column 1: start pos
    ## column 2: end pos
    ## column 4: data type (AN or N)
    [tokens[0].intern, tokens[1].to_i, tokens[2].to_i, tokens[4]]
  end
  
  def _parse_file(file, layout, model)
    attributes = {}
    cnt = 0
    while (line = file.gets) do
      next if line.strip == ''
      attributes.clear
      layout.each do |label, start_pos, end_pos, data_type|
        data_str = line[(start_pos-1)..(end_pos-1)].gsub(/[^[:print:]]/, '')
        data_value = data_type == 'N' ? data_str.to_i : data_str
        attributes[label] = data_value
      end
      rec = model.new(attributes)
      rec.save!
      cnt += 1
      putc('.') if cnt % 100 == 0
    end
    puts "\n#{cnt} records saved from #{file.path}"
  end
  
end

class NcesMigrationGenerator
  
  def initialize(district_layout, school_layout, year_str)
    @district_layout = district_layout
    @school_layout = school_layout
    @text = ''
    @migration_file_name = "create_nces#{year_str}_tables.rb"
    @migration_class_name = "CreateNces#{year_str}Tables"
    @district_db_name = "nces#{year_str}_districts"
    @school_db_name = "nces#{year_str}_schools"
  end
  
  def write
    open(_get_file_path, 'w') do |f|
      f.write(_getText)
    end
  end
  
private  

  def _get_file_path
    timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    File.join('db', 'migrate', "#{timestamp}_#{@migration_file_name}")
  end
  
  def _getText
    @text << "class #{@migration_class_name} < ActiveRecord::Migration\n\n"
    @text << "  def self.up\n"
    @text << "    create_table :#{@district_db_name} do |t|\n"
    @text << _getFieldsText(@district_layout)
    @text << "    end\n"
    @text << "    create_table :#{@school_db_name} do |t|\n"
    @text << _getFieldsText(@school_layout)
    @text << "    end\n"
    @text << "  end\n\n"
    @text << "  def self.down\n"
    @text << "    drop_table :#{@district_db_name}\n"
    @text << "    drop_table :#{@school_db_name}\n"
    @text << "  end\n\n"
    @text << "end\n"
  end
  
  def _getFieldsText(layout)
    text = ''
    indent = ' ' * 6
    layout.each do |column_def|
      text << indent << (column_def[3] == 'N' ? 't.integer ' : 't.text ')
      text << ":#{column_def[0]}\n"
    end
    text
  end

end
