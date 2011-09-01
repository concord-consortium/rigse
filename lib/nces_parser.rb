# gem 'ar-extensions', '>= 0.9.1'
require 'ar-extensions'

class NcesParser
  
  def initialize(district_layout_file, school_layout_file, year, states_and_provinces=nil)
    ## @year_str gets inserted to the db table names
    @year_str = year.to_s[-2..-1]
    puts 'Parsing layout files:'
    @district_layout = _get_district_layout(district_layout_file)
    puts "  #{@district_layout.size} variables retrieved from #{district_layout_file}"
    @school_layout = _get_school_layout(school_layout_file)
    puts "  #{@school_layout.size} variables retrieved from #{school_layout_file}"
    
    @district_model = "Portal::Nces#{@year_str}District".constantize
    @school_model = "Portal::Nces#{@year_str}School".constantize
    
    # states_and_provinces should either be nil to import data from ALL states and provinces
    # or equal to an array of state and province abbreviation strings.
    # The rake task that calls this class loads this value like this:
    # states_and_provinces = APP_CONFIG[:states_and_provinces] 
    # which as an example might be equal to: ["RI", "MA"]
    @states_and_provinces = states_and_provinces
  end
  
  def create_tables_migration
    migration = NcesMigrationGenerator.new(@district_layout, @school_layout, @year_str)
    migration.write_tables_migration
  end

  def create_indexes_migration
    migration = NcesMigrationGenerator.new(@district_layout, @school_layout, @year_str)
    migration.write_indexes_migration
  end
  
  def load_db(district_data_files, school_data_files)
    ## Delete all the entries first
    ## Use the TRUNCATE cammand -- works in mysql to effectively empty the database and reset 
    ## the autogenerating primary key index ... not certain about other databases
    if @states_and_provinces && @states_and_provinces.empty?
      print "\nNot importing any schools -- states_and_provinces is an empty array []"
    else
      print "\nImporting School data "
      if @states_and_provinces
        puts "for the following states and provinces: #{@states_and_provinces.join(', ')}."
      else
        puts "for all states and provinces ... this will take a while ..."
      end
      ActiveRecord::Base.connection.delete("TRUNCATE `#{@district_model.table_name}`")
      ActiveRecord::Base.connection.delete("TRUNCATE `#{@school_model.table_name}`")
      puts
      puts "Loading district data:"
      district_data_files.each do |fpath|
        open(fpath) do |file|
          _parse_file_using_import(file, @district_layout, @district_model)
        end
      end
      puts "\n#{@district_model.count} #{@district_model.name} records created"
      puts
      puts "Loading school data:"
      school_data_files.each do |fpath|
        open(fpath) do |file|
          _parse_file_using_import(file, @school_layout, @school_model)
        end
      end
      puts "\n#{@school_model.count} #{@school_model.name} records created"
      puts
      puts "Generating #{@school_model.count} #{@school_model.name} 'belongs_to :nces_district' associations:"
      # _parseDistrictSchoolAssociations
      _parseDistrictSchoolAssociationWithIndex
      puts
    end
  end

private

  # these constants are used in the instance methods for
  # generating layouts and migrations
  #
  # NCES_DECIMAL_TYPE is a derived type meaning Decimal
  # if the original NCES length value is suffixed with an '*' 
  # that means the field value has a decimal point
  
  NCES_STRING_TYPE    = "AN"
  NCES_NUMBER_TYPE    = "N"
  NCES_DECIMAL_TYPE   = "D"
  ASTERISK_CHAR       = 42
  
  def _get_school_layout(layout_file)
    columns = []
    open(layout_file) do |file|
      count = 0
      line = ''
      while (line = file.gets) && count < 2 do #fast forward until real data begins
        count += 1 if line =~ /=====/
      end
      while line do
        unless line =~ /\A\s/
          field_description = line.split(/\s\s\s+/).collect {|i| i.split(/\t+/)}.flatten
          # strip any whitespace from the field name and trim '+' prefix if it exists
          field_description[0].strip!
          field_description[0].gsub!(/^\+/, '')
          # if the remaining field name is more than 3 chars in length 
          # trim  any '06' suffix if it exists
          if field_description[0].length > 3
            field_description[0].gsub!(/06$/, '')
          end
          # replace fields named 'TYPE' with 'KIND' to
          # avoid dealing with Rails single_table type magic
          field_description[0] = 'KIND' if field_description[0] == 'TYPE'
          # check to see if the field type should be Decimal
          if field_description[3].last == ASTERISK_CHAR
            field_description[4] = NCES_DECIMAL_TYPE
            field_description[3].chop
          end
          # convert positions and lengths to Integers
          field_description[1] = field_description[1].to_i
          field_description[2] = field_description[2].to_i
          field_description[3] = field_description[3].to_i
          # make sure the description is not nil and has one newline
          field_description[5] ||= ""
          field_description[5].strip!
          field_description[5] << "\n"
          columns << field_description
        end
        line = file.gets
      end
    end
    columns
  end

  def _get_district_layout(layout_file)
    columns = []
    open(layout_file) do |file|
      count = 0
      line = ''
      while (line = file.gets) && count < 2 do #fast forward until real data begins
        count += 1 if line =~ /=====/
      end
      while line do
        unless line =~ /\A\s/
          ## layouts are an array of arrays
          ## [ [c1, s1, e1, l1, t1, d1], [c2, s2, e2, l2, t2, d2] where
          ## cn: c[0]: column code (e.g. NCESSCH)
          ## sn: c[1]: start pos
          ## en: c[2]: end pos
          ## ln: c[3]: length (if suffixed with an '*' the field value includes a decimal point)
          ## tn: c[4]: data type (AN, N, or D)
          ## dn: c[5]: description
          field_description = line.unpack("A16A8A8A16A8A*")
          # strip any whitespace from the field name and trim '+' prefix if it exists
          field_description[0].strip!
          field_description[0].gsub!(/^\+/, '')
          # if the remaining field name is more than 3 chars in length 
          # trim  any '06' suffix if it exists
          if field_description[0].length > 3
            field_description[0].gsub!(/06$/, '')
          end
          # replace fields named 'TYPE' with 'KIND' to
          # avoid dealing with Rails single_table type magic
          field_description[0] = 'KIND' if field_description[0] == 'TYPE'
          # check to see if the field type should be Decimal
          if field_description[3].last == ASTERISK_CHAR
            field_description[4] = NCES_DECIMAL_TYPE
            field_description[3].chop
          end
          # convert positions and lengths to Integers
          field_description[1] = field_description[1].to_i
          field_description[2] = field_description[2].to_i
          field_description[3] = field_description[3].to_i
          # make sure the description is not nil and has one newline
          field_description[5] ||= ""
          field_description[5].strip!
          field_description[5] << "\n"
          columns << field_description
        end
        line = file.gets
      end
    end
    columns
  end
  
  # Parses the data for either districts or schools
  #
  # Uses the gem ar-extensions to do faster importing.
  # see: http://github.com/zdennis/ar-extensions/tree/master
  #      http://www.continuousthinking.com/tags/arext
  #
  def _parse_file_using_import(file, layout, model)
    attributes = {}
    count = 0
    value_sets = []
    column_names = model.columns.map{ |column| column.name }
    not_nces_fields = column_names.select { |name| name[/id/] }
    field_names = column_names - not_nces_fields
    options = { :validate => false }
    mstate_index = field_names.index("MSTATE")
    while (line = file.gets) do
      next if line.strip == ''
      values = []
      layout.each do |label, start_pos, end_pos, length, data_type, description|
        data_str = line[(start_pos-1)..(end_pos-1)].strip.gsub(/[^[:print:]]/, '')
        data_value = case data_type
        when 'N'
          data_str.to_i
        when 'D'
          data_str.to_f
        else
          data_str
        end
        values << data_value
      end
      if @states_and_provinces
        if @states_and_provinces.include?(values[mstate_index])
          value_sets << values
        end
      else
        value_sets << values
      end
      if value_sets.length >= 10
        records = model.import(field_names, value_sets, options)
        value_sets = values = []
      end
      count += 1
      if count % 500 == 0
        print '.'
        STDOUT.flush
      end
    end
    if value_sets.length > 0
      model.import(field_names, value_sets, options)
    end    
    puts "\n#{count} records processed from #{file.path}"
  end
  
  # Creates the AR association: Nces06District 'has_many :nces_schools'
  # for the Nces06Schools
  #
  # This uses find_by_sql to load shallow instance of the models -- only 
  # the attributes needed are loaded into memory.
  #
  # FIXME: the performance of nces_districts.detect becomes much slower as the
  # key being searched for is near the end of the array of districts (> 18,000).
  #
  # However for 18,000 record it's still about twice as fast as using a Hash lookup
  def _parseDistrictSchoolAssociations
    nces_districts = @district_model.find_by_sql("SELECT id,LEAID from #{Portal::Nces06District.table_name}")
    district_id_and_leaid_array = nces_districts.collect { |d| [d.id, d.LEAID] }
    
    nces_schools = @school_model.find_by_sql("SELECT id, nces_district_id, LEAID from #{Portal::Nces06School.table_name}")
    count = 0
    status = '.'
    nces_schools.each do |nces_school|
      leaid = nces_school.LEAID
      district_id_and_leaid = district_id_and_leaid_array.detect { |d| d[1] == leaid }
      if district_id_and_leaid
        nces_school.nces_district_id = district_id_and_leaid[0]
      else
        status = 'x'
      end
      count += 1
      if count % 500 == 0
        print status
        STDOUT.flush
        status = '.'
      end
    end
  end

  def _parseDistrictSchoolAssociationWithIndex
    nces_schools = @school_model.find_by_sql("SELECT id, nces_district_id, LEAID from #{@school_model.table_name}")
    count = 0
    status = '.'
    nces_schools.each do |nces_school|
      leaid = nces_school.LEAID
      nces_district = @district_model.find_by_sql("SELECT id from `#{@district_model.table_name}` WHERE `LEAID` LIKE '#{nces_school.LEAID}'").first
      if nces_district
        nces_school.nces_district_id = nces_district.id
        nces_school.save!
      else
        status = 'x'
      end
      count += 1
      if count % 500 == 0
        print status
        STDOUT.flush
        status = '.'
      end
    end
  end
end

class NcesMigrationGenerator
  
  def initialize(district_layout, school_layout, year_str)
    @year_str = year_str
    @district_layout = district_layout
    @school_layout = school_layout
    @text = ''
    @tables_migration_file_name = "create_nces#{@year_str}_tables.rb"
    @tables_migration_class_name = "CreateNces#{@year_str}Tables"
    @district_table_name = "portal_nces#{@year_str}_districts"
    @school_table_name = "portal_nces#{@year_str}_schools"
    @indexes_migration_file_name = "create_nces#{@year_str}_indexs.rb"
    @indexes_migration_class_name = "CreateNces#{@year_str}Indexes"    
  end
  
  def write_tables_migration
    open(_get_file_path(@tables_migration_file_name), 'w') do |f|
      f.write(_getTablesText)
    end
  end

  def write_indexes_migration
    open(_get_file_path(@indexes_migration_file_name), 'w') do |f|
      f.write(_getIndexesText)
    end
  end
  
private  

  def _get_file_path(migration_file_name)
    timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    File.join(::Rails.root.to_s, 'db', 'migrate', "#{timestamp}_#{migration_file_name}")
  end

  def _getIndexesText
    district_index_fields = %w{LEAID STID NAME}
    school_index_fields   = %w{NCESSCH STID SCHNAM}
    @text << "class #{@indexes_migration_class_name} < ActiveRecord::Migration\n"
    @text << "  def self.up\n"
    @text <<     _getDistrictIndexs(district_index_fields, 'add_index')
    @text << "\n"
    @text <<     _getSchoolIndexs(school_index_fields, 'add_index')
    @text << "  end\n\n"
    @text << "  def self.down\n"
    @text <<     _getDistrictIndexs(district_index_fields, 'remove_index')
    @text << "\n"
    @text <<     _getSchoolIndexs(school_index_fields, 'remove_index')
    @text << "  end\n"
    @text << "end\n"
  end

  def _getDistrictIndexs(index_fields, index_command)
    index_fields.collect do |field_name| 
      _getIndexText(field_name, @district_layout, @district_table_name, index_command)
    end.join
  end

  def _getSchoolIndexs(index_fields, index_command)
    index_fields.collect do |field_name| 
      _getIndexText(field_name, @school_layout, @school_table_name, index_command)
    end.join
  end

  def _getTablesText
    @text << "class #{@tables_migration_class_name} < ActiveRecord::Migration\n\n"
    @text << "  def self.up\n"
    @text << "    create_table :#{@district_table_name} do |t|\n"
    @text << _getFieldsText(@district_layout)
    @text << "    end\n"
    @text << "\n\n"
    @text << "    create_table :#{@school_table_name} do |t|\n"
    @text << "      t.integer :nces_district_id\n"
    @text << _getFieldsText(@school_layout)
    @text << "    end\n"
    @text << "  end\n\n"
    @text << "  def self.down\n"
    @text << "    drop_table :#{@district_table_name}\n"
    @text << "    drop_table :#{@school_table_name}\n"
    @text << "  end\n\n"
    @text << "end\n"
  end

  # these constants are used in the following two instance
  # methods that generate lines for the index and table migrations
  STRING_FIELD_LAYOUT = "      %-10s%-12s%-18s%-20s"
  NUMBER_FIELD_LAYOUT = "      %-10s%-30s%-20s"
  INDEX_FIELD_LAYOUT  = "    %-14s%-34s%-12s%-20s"
  STRING_FIELD        = "t.string"
  FLOAT_FIELD         = "t.float"
  INTEGER_FIELD       = "t.integer"
  DECIMAL_FIELD       = "t.decimal"
  STRING_LIMIT        = ":limit => "

  def _getIndexText(field_name, layout, table_name, index_command)
    field_def = layout.find { |column_def| column_def[0] == field_name }
    field_comment = (field_def ? field_def[5] : " \n")
    text = sprintf(INDEX_FIELD_LAYOUT, index_command, ":#{table_name},", ":#{field_name}", '# '+field_comment)
  end

  def _getFieldsText(layout)
    text = ''
    layout.each do |column_def|
      if column_def[4] == NCES_STRING_TYPE && column_def[3][-1] != ASTERISK_CHAR
        text << sprintf(STRING_FIELD_LAYOUT, STRING_FIELD, ":#{column_def[0]},", STRING_LIMIT+column_def[3], '# '+column_def[5] )
      else
        # if the length string is suffixed with a "*" then the number has a decimal point
        if column_def[3][-1] == ASTERISK_CHAR
          text << sprintf(NUMBER_FIELD_LAYOUT, FLOAT_FIELD, ":#{column_def[0]}", '# '+column_def[5] )
        else
          text << sprintf(NUMBER_FIELD_LAYOUT, INTEGER_FIELD, ":#{column_def[0]}", '# '+column_def[5] )
        end
      end
    end
    text
  end

end
