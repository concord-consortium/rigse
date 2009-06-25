namespace :rigse do
  namespace :import do

    require 'hpricot'
    require 'fileutils'
    # require 'otrunk_examples_import'
    autoload :OtrunkExampleImport, "otrunk_examples_import"
    def otrunk_lib_dir
      @otrunk_lib_dir || @otrunk_lib_dir = File.join(RAILS_ROOT, 'lib', 'otrunk')
    end

    def otrunk_examples_dir
      @otrunk_examples_dir || @otrunk_examples_dir = File.join(RAILS_ROOT, 'public', 'otrunk-examples')
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
      File.join(RAILS_ROOT, 'lib', 'otrunk', 'ot_introspect.yaml')
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
      Dir["#{otrunk_examples_dir}/**/*.otml"].each do |f| 
        doc = Hpricot.XML(open(f)) 
        otrunk_imports << doc.search("//import").collect {|i| i['class']} 
      end 
      otrunk_imports.flatten!.uniq!
      File.open(otrunk_model_classes_path, 'w') { |f| f.write(YAML.dump(otrunk_imports)) }
    end
    
    desc "Generate OtrunkExamples:: Rails models from the content in the otrunk-examples dir."
    task :generate_otrunk_examples_rails_models => :create_or_update_otrunk_examples do
      puts "\nintrospecting otrunk-examples ...\n"
      ot = OtrunkExampleImport::OtIntrospect.new(otrunk_examples_dir)
      puts "\ncreating #{ot.categories.length} OtmlCategory objects:"
      ot.categories.each do |otc|
        unless OtrunkExample::OtmlCategory.find_by_name(otc)
          print 'o'
          OtrunkExample::OtmlCategory.create!(:name => otc)
        end
      end

      c1 = OtrunkExample::OtmlCategory.find(:all)[1]; puts "\n\nOtmlCategory: 1: otrunk_imports.length: #{c1.otrunk_imports.length}"
      
      puts "\n\ncreating #{ot.otml_files.length} OtmlFile objects: "
      ot.otml_files.each do |otf|
        unless OtrunkExample::OtmlFile.find(:first, :conditions => { :path => otf.path })
          ar_otml_category = OtrunkExample::OtmlCategory.find_by_name(otf.category)
          attributes = {
            :name => otf.name, 
            :path => otf.path, 
            :otml_category_id => ar_otml_category.id
          }
          OtrunkExample::OtmlFile.create!(attributes)
          print 'o'
        else
          print '.'
        end
      end
      
      c2 = OtrunkExample::OtmlCategory.find(:all)[2]; puts "\n\nOtmlCategory: 2: otrunk_imports.length: #{c2.otrunk_imports.length}"

      puts "\n\ncreating #{ot.otml_imports.length} OtrunkImport objects: "
      ot.otml_imports.each do |oti|
        unless OtrunkExample::OtrunkImport.find(:first, :conditions => { :fq_classname => oti.fq_classname })
          OtrunkExample::OtrunkImport.create!(:classname => oti.classname, :fq_classname => oti.fq_classname)
          print 'o'
        else
          print '.'
        end
      end
      
      c3 = OtrunkExample::OtmlCategory.find(:all)[3]; puts "\n\nOtmlCategory: 2: otrunk_imports.length: #{c3.otrunk_imports.length}"

      puts "\n\ncreating #{ot.otml_view_entries.length} OtrunkViewEntry objects: "
      ot.otml_view_entries.each do |otve|
        if otve
          ar_otrunk_import = OtrunkExample::OtrunkImport.find_by_fq_classname(otve.fq_object_classname)
          ar_otrunk_view_entry = OtrunkExample::OtrunkViewEntry.find(:first, :conditions => { :fq_classname => otve.fq_view_classname })
          if ar_otrunk_import && !ar_otrunk_view_entry
            attributes = {
              :classname => otve.view_classname, 
              :fq_classname => otve.fq_view_classname, 
              :otrunk_import_id => ar_otrunk_import.id
            }
            OtrunkExample::OtrunkViewEntry.create!(attributes)
            print 'o'
          else
            print '.'
          end
        else
          print 'x'
        end
      end
      
      c4 = OtrunkExample::OtmlCategory.find(:all)[4]; puts "\n\nOtmlCategory: 4: otrunk_imports.length: #{c4.otrunk_imports.length}"

      puts "\n\ncreating has_and_belongs_to_many associations:\n"
      puts "associating otml_files with otrunk_imports and otrunk_view_entries ..."
      ot.otml_files.each do |otfile|
        print 'o'
        ar_otml_file = OtrunkExample::OtmlFile.find_by_path(otfile.path)
        otfile.imports.each do |import|
          ar_otml_import = OtrunkExample::OtrunkImport.find_by_fq_classname(import)
          unless ar_otml_file.otrunk_imports.exists?(ar_otml_import)
            ar_otml_file.otrunk_imports << ar_otml_import
          end
        end
        otfile.view_entries.each do |ve|
          ar_otml_view_entry = OtrunkExample::OtrunkViewEntry.find_by_fq_classname(ve[0])
          if ar_otml_view_entry && !ar_otml_file.otrunk_view_entries.exists?(ar_otml_view_entry)
            ar_otml_file.otrunk_view_entries << ar_otml_view_entry
          end
        end
      end
      
      c5 = OtrunkExample::OtmlCategory.find(:all)[5]; puts "\n\nOtmlCategory: 5: otrunk_imports.length: #{c5.otrunk_imports.length}"
      
      puts "\nassociating otml_categories with otrunk_imports ..."
      OtrunkExample::OtmlCategory.find(:all).each do |ar_ot_category|
        print 'o'
        ot_imports = []
        ar_ot_category.otml_files.each do |ot_file|
          ot_imports << ot_file.otrunk_imports
        end
        ot_imports.flatten! ? ot_imports.uniq! : ot_imports = []
        ot_imports.each do |ar_import|
          if ar_import &&  !ar_ot_category.otrunk_imports.exists?(ar_import)
            ar_ot_category.otrunk_imports << ar_import
          end
        end
      end
      
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
      
    end
  end
end


