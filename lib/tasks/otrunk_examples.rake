namespace :app do
  namespace :import do
    
    require 'fileutils'
    # require 'otrunk_examples_import'
    autoload :OtrunkExampleImport, "otrunk_examples_import"
    def otrunk_lib_dir
      @otrunk_lib_dir || @otrunk_lib_dir = File.join(::Rails.root.to_s, 'lib', 'otrunk')
    end

    def otrunk_examples_dir
      @otrunk_examples_dir || @otrunk_examples_dir = File.join(::Rails.root.to_s, 'public', 'otrunk-examples')
    end

    def otrunk_model_classes_path
      @otrunk_model_classes_path || @otrunk_model_classes_path = File.join(otrunk_lib_dir, 'otrunk_model_classes.yaml')
    end
    
    def ot_introspect_object
      @ot_introspect_object || load_ot_introspect_object
    end

    def load_ot_introspect_object
      if File.exists?(ot_introspect_object_path)
        @ot_introspect_object = YAML.load(File.read(ot_introspect_object_path))
      else
        update_ot_introspect_object
      end
    end

    def update_ot_introspect_object
      @ot_introspect_object = OtrunkExampleImport::OtIntrospect.new(otrunk_examples_dir)
      save_ot_introspect_object
    end

    def save_ot_introspect_object
      File.open(ot_introspect_object_path, 'w') do |f|
        f.write YAML.dump(@ot_introspect_object)
      end
      @ot_introspect_object
    end

    def ot_introspect_object_path
      File.join(::Rails.root.to_s, 'lib', 'otrunk', 'ot_introspect.yaml')
    end
    
    def git_update_otrunk_examples
      Dir.chdir(otrunk_examples_dir) do
        puts "\nupdating local git repository of otrunk-examples: #{otrunk_examples_dir}"
        `git pull`
      end
    end

    def git_clone_otrunk_examples
      Dir.chdir(File.dirname(otrunk_examples_dir)) do
        puts "\ncreating local git repository of otrunk-examples: #{otrunk_examples_dir}"
        `git clone git://github.com/stepheneb/otrunk-examples.git`
      end      
    end

    desc "create or update a git clone of otrunk-examples in lib/otrunk/otrunk-examples"
    task :create_or_update_otrunk_examples => :environment do
      FileUtils.mkdir_p(otrunk_lib_dir) unless File.exists? otrunk_lib_dir
      if File.exists? File.join(otrunk_examples_dir, '.git')
        git_update_otrunk_examples
      else
        git_clone_otrunk_examples
      end
    end
    
    desc 'delete the otrunk-example models (Rails models)'
    task :delete_otrunk_example_models => :environment do
      # The TRUNCATE cammand works in mysql to effectively empty the database and reset 
      # the autogenerating primary key index ... not certain about other databases
      puts
      puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{OtrunkExample::OtmlCategory.table_name}`")} from OtrunkExample::OtmlCategory"
      puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{OtrunkExample::OtmlFile.table_name}`")} from OtrunkExample::OtmlFile"
      puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{OtrunkExample::OtrunkImport.table_name}`")} from OtrunkExample::OtrunkImport"
      puts "deleted: #{ActiveRecord::Base.connection.delete("TRUNCATE `#{OtrunkExample::OtrunkViewEntry.table_name}`")} from OtrunkExample::OtrunkViewEntry"
      
      OtrunkExample::OtmlCategory.reset_column_information
      OtrunkExample::OtmlFile.reset_column_information
      OtrunkExample::OtrunkImport.reset_column_information
      OtrunkExample::OtrunkViewEntry.reset_column_information
      
      # ClassName.delete_all version should also work but it doesn't reset the priamry key generator
      # puts "deleted: #{OtrunkExample::OtmlFile.delete_all} from OtrunkExample::OtmlFile"
      # puts "deleted: #{OtrunkExample::OtrunkViewEntry.delete_all} from OtrunkExample::OtrunkViewEntry"
      # puts "deleted: #{OtrunkExample::OtrunkImport.delete_all} from OtrunkExample::OtmlFile"
      # puts "deleted: #{OtrunkExample::OtmlCategory.delete_all} from OtrunkExample::OtrunkImport"

      deleted_otml_files_otrunk_view_entries = ActiveRecord::Base.connection.delete("DELETE FROM `otml_files_otrunk_view_entries`")
      puts "deleted: #{deleted_otml_files_otrunk_view_entries} from habtm join table: otml_files_otrunk_view_entries"
      deleted_otml_files_otrunk_imports = ActiveRecord::Base.connection.delete("DELETE FROM `otml_files_otrunk_imports`")
      puts "deleted: #{deleted_otml_files_otrunk_imports} from habtm join table: otml_files_otrunk_imports"
      deleted_otml_categories_otrunk_imports = ActiveRecord::Base.connection.delete("DELETE FROM `otml_categories_otrunk_imports`")
      puts "deleted: #{deleted_otml_categories_otrunk_imports} from habtm join table: otml_categories_otrunk_imports"
      puts
    end
    
    desc "create or update: #{otrunk_model_classes_path}"
    task :create_or_update_otrunk_model_classes => :create_or_update_otrunk_examples do
      puts "\nupdating #{otrunk_model_classes_path} ..."
      otrunk_imports = []
      otml_files = Dir["#{otrunk_examples_dir}/**/*.otml"].find_all {|o| !(o =~ /rites/) }
      otml_files.each do |f| 
        puts "#{File::stat(f).size}: #{f}"
        doc = Nokogiri.XML(open(f)) 
        otrunk_imports << doc.search("//import").collect {|i| i['class']} 
      end 
      otrunk_imports.flatten!.uniq!
      File.open(otrunk_model_classes_path, 'w') { |f| f.write(YAML.dump(otrunk_imports)) }
    end
    
    desc "Generate OtrunkExamples:: Rails models from the content in the otrunk-examples dir."
    task :generate_otrunk_examples_rails_models => :create_or_update_otrunk_examples do
      puts "\nintrospecting otrunk-examples ...\n"
      ot = OtrunkExampleImport::OtIntrospect.new(otrunk_examples_dir)
      ot.create_otml_categories
      ot.create_otml_files
      ot.create_otrunk_imports
      ot.create_otml_view_entries
      ot.create_otml_file_associations
      ot.create_otml_category_associations
      # ot.create_otml_category_associations            
      puts "\n\n"
      puts "OtrunkExample::OtmlFile.count: #{OtrunkExample::OtmlFile.count}"
      puts "OtrunkExample::OtrunkViewEntry.count: #{OtrunkExample::OtrunkViewEntry.count}"
      puts "OtrunkExample::OtrunkImport.count: #{OtrunkExample::OtrunkImport.count}"
      puts "OtrunkExample::OtmlCategory.count: #{OtrunkExample::OtmlCategory.count}"

      otml_files_otrunk_view_entries = ActiveRecord::Base.connection.select_value("SELECT count(*) AS count_all FROM `otrunk_example_otml_files`")
      puts "otml_files_otrunk_view_entries joins: #{otml_files_otrunk_view_entries}"
      otml_files_otrunk_imports = ActiveRecord::Base.connection.select_value("SELECT count(*) AS count_all FROM `otml_files_otrunk_imports`")
      puts "otml_files_otrunk_imports joins: #{otml_files_otrunk_imports}"
      otml_categories_otrunk_imports = ActiveRecord::Base.connection.select_value("SELECT count(*) AS count_all FROM `otml_categories_otrunk_imports`")
      puts "otml_categories_otrunk_imports joins: #{otml_categories_otrunk_imports}"
      puts
    end
  end
end


