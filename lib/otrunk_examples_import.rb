class OtrunkExampleImport
  require 'open-uri'
  require 'fileutils'

  require 'set'
  require 'arrayfields'

  ViewEntry = Array.struct :fq_view_classname, :fq_object_classname

  module AttributeHelper
    def attribute_value(css_selector, attribute)
      element = @doc.at_css(css_selector)
      element ? element[attribute] : nil
    end
    
    def attribute_values(css_selector, attribute)
      elements = @doc.css(css_selector)
      elements.collect {|i| i[:attribute]}
    end
  end
  
  class OtFile
    attr_accessor :path, :name, :category, :last_modified, :file_size, :imports, :view_entries
    def initialize(path)
      @path = path
      @name = File.basename(path)
      @category =  File.basename(File.dirname(@path))
      @last_modified =  File.ctime(@path)
      @file_size = File.stat(path).size
      doc_local_var = doc
      @imports = doc_local_var.search("import").collect { |e| e[:class] }
      @view_entries = doc_local_var.search("OTViewEntry").collect {|ve| ViewEntry.new([ve[:viewClass], ve[:objectClass]])}
      # end
    end

    def doc
      Nokogiri::XML(File.read(path))
    end
  end

  class OtImport
    attr_accessor :fq_classname, :classname, :otml_files
    def initialize(klass, otml_files=nil)
      @fq_classname = klass
      @classname = klass.split('.')[-1]
      @otml_files = Set.new
      if otml_files then @otml_files.merge(otml_files)
      end
    end
  end

  class OtViewEntry
    attr_accessor :fq_view_classname, :view_classname, :fq_object_classname, :object_classname, :otml_files
    def initialize(view_entry, otml_files=nil)
      @fq_view_classname = view_entry[:fq_view_classname]
      @view_classname = @fq_view_classname.split('.')[-1]
      @fq_object_classname = view_entry[:fq_object_classname]
      @object_classname = @fq_object_classname.split('.')[-1]
      @otml_files = Set.new
      if otml_files then @otml_files.merge(otml_files)
      end
    end
  end

  class OtLaunchFile
    include AttributeHelper
    attr_accessor :path, :name, :body, :doc, :launch_type, :project_name, :projects_dir, :class_dir, :category,
    :projects, :internal_archives, :main_type, :program_arguments, :vm_arguments, :valid
    def initialize(path)
      @path = path
      @name = File.basename(@path).chomp('.launch')
      @body = File.read(@path)
      @doc = Nokogiri::XML(@body)
      @launch_type = @doc.at_css("launchConfiguration")[:type]
      list_entry_values = @doc.search("listAttribute[@key='org.eclipse.jdt.launching.CLASSPATH']/listEntry").collect {|le| le[:value]}
      project_attr = @doc.at_css("stringAttribute[@key='org.eclipse.jdt.launching.PROJECT_ATTR']")
      if project_attr
        @project_name = project_attr[:value]
      else
        @project_name = 'unnamed'
      end
      @projects_dir = @path.split(project_name)[0]
      @category = @path[/#{@project_name}\/(.*)\//, 1]
      @internal_archives = []
      @projects = []
      @valid = true
      list_entry_values.each do |val|
        value = Nokogiri::XML(val)
        if project = value.at_css("runtimeClasspathEntry")[:projectName]
          path = @projects_dir + project
          if File.exists?("#{path}/.classpath")
            classpath = Nokogiri.XML(open("#{path}/.classpath"))
            output = classpath.at("classpathentry[@kind=output]")[:path]
            @projects <<  "#{path}/#{output}"
          else
            @valid = false
            @projects <<  "#{path}/no-classpath-found"
          end
        elsif archive = value.at_css("runtimeClasspathEntry")[:internalArchive]
          @internal_archives << @projects_dir.chomp('/') + archive
        end
      end
      @main_type = attribute_value("stringAttribute[@key='org.eclipse.jdt.launching.MAIN_TYPE']", :value)
      @program_arguments = attribute_values("stringAttribute[@key='org.eclipse.jdt.launching.PROGRAM_ARGUMENTS']", :value)
      @vm_arguments = attribute_values("stringAttribute[@key='org.eclipse.jdt.launching.VM_ARGUMENTS']", :value)
    end
  end

  class OtIntrospect
    attr_accessor :otml_files, :otml_imports, :otml_view_entries, :otml_launch_files, :imports, 
    :view_entries, :projects, :internal_archives, :categories
    def initialize(dir='.')
      @otml_files, @otml_imports, @otml_view_entries, @otml_launch_files  = [], [], [], []
      @imports, @view_entries, @projects, @internal_archives, @categories = [], [], [], [], []
      count = 1
      files = Dir["#{dir}/**/*.launch"]
      eclipse_launch_format_str  = "%4d:  %s"
      puts "\n\nprocessing #{files.length} Eclipse launch files: "
      files.each do |file_path|
        file_display_path = file_path.gsub(Rails.root.to_s, '.')
        puts sprintf(eclipse_launch_format_str, count, file_display_path)
        count += 1
        @otml_launch_files << OtLaunchFile.new(file_path)
        @projects += (@otml_launch_files[-1].projects || [])
        @internal_archives += (@otml_launch_files[-1].internal_archives || [])
        @categories += [@otml_launch_files[-1].category]
      end
      @projects.uniq!
      @internal_archives.uniq!
      count = 1
      files = Dir["#{dir}/**/*.otml"].find_all {|o| !(o =~ /rites/) }
      otml_file_format_str  = "%4d: %4.0dk:  %-s"
      otml_file_empty_str   = " *** skipped because there were no imports in the file: %s"
      puts "\n\nprocessing #{files.length} otml files: "
      files.in_groups_of(10, false) do |file_group|
        file_group.each do |file_path|
          file_size = File.stat(file_path).size / 1024
          file_display_path = file_path.gsub(Rails.root.to_s, '.')
          puts sprintf(otml_file_format_str, count, file_size, file_display_path)
          otf  = OtFile.new(file_path)
          unless otf.imports.empty?
            @otml_files << otf
            @imports += @otml_files[-1].imports
            @view_entries += @otml_files[-1].view_entries
            @categories += [@otml_files[-1].category]
          else
            puts sprintf(otml_file_empty_str, file_display_path)
          end 
          count += 1
        end
      end
      @imports.uniq!
      @view_entries.uniq!
      @categories.uniq!
      @imports.each do |import|
        @otml_imports << OtImport.new(import, @otml_files.reject {|f| (f.imports & [import]).empty?})
      end
      count = 1
      view_entry_format_str       = "%4d:  %-70s   =>   %s"
      view_entry_format_str_empty = "%4d:  *** empty view entry ???"
      puts "\n\nprocessing #{@view_entries.length} otml view entries: "
      @view_entries.in_groups_of(10, false) do |view_entry_group|
        view_entry_group.each do |ve|
          if ve.compact.length == 2
            ot_ve = OtViewEntry.new(ve, @otml_files.reject {|f| (f.view_entries & @view_entries).empty?})
            @otml_view_entries << ot_ve
            puts sprintf(view_entry_format_str, count, ot_ve.fq_object_classname, ot_ve.fq_view_classname)
          else
            puts sprintf(view_entry_format_str_empty, count)
          end
          count += 1
        end
      end
      puts "\n\n"
      artifact_types = %w{otml_files otml_imports otml_view_entries otml_launch_files projects internal_archives}
      artifact_types.each { |artifact_type| puts sprintf("%-20s %-s", "#{artifact_type}:", "#{self.send(artifact_type).length}") }
    end

    def create_otml_categories
      puts "\ncreating #{self.categories.length} OtmlCategory objects: "
      self.categories.each do |otc|
        if OtrunkExample::OtmlCategory.find_by_name(otc)
          print '.'; STDOUT.flush
        else
          print 'o'; STDOUT.flush
          OtrunkExample::OtmlCategory.create!(:name => otc)
        end
      end
    end

    def create_otml_files
      puts "\n\ncreating #{self.otml_files.length} OtmlFile objects: "
      self.otml_files.in_groups_of(72, false).each do |otf_group|
        otf_group.each do |otf|
          unless OtrunkExample::OtmlFile.find(:first, :conditions => { :path => otf.path })
            ar_otml_category = OtrunkExample::OtmlCategory.find_by_name(otf.category)
            attributes = {
              :name => otf.name, 
              :path => otf.path, 
              :otml_category_id => ar_otml_category.id
            }
            OtrunkExample::OtmlFile.create!(attributes)
            print 'o'; STDOUT.flush
          else
            print '.'; STDOUT.flush
          end
        end
        puts
      end
    end

    def create_otrunk_imports
      puts "\n\ncreating #{self.otml_imports.length} OtrunkImport objects: "
      self.otml_imports.in_groups_of(72, false).each do |oti_group|
        oti_group.each do |oti|
          unless OtrunkExample::OtrunkImport.find(:first, :conditions => { :fq_classname => oti.fq_classname })
            OtrunkExample::OtrunkImport.create!(:classname => oti.classname, :fq_classname => oti.fq_classname)
            print 'o'; STDOUT.flush
          else
            print '.'; STDOUT.flush
          end
        end
        puts
      end
    end

    def create_otml_view_entries
      puts "\n\ncreating #{self.otml_view_entries.length} OtrunkViewEntry objects: "
      self.otml_view_entries.in_groups_of(72, false).each do |otve_group|
        otve_group.each do |otve|
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
              print 'o'; STDOUT.flush
            else
              print '.'; STDOUT.flush
            end
          else
            print 'x'; STDOUT.flush
          end
        end
        puts
      end
    end

    def create_otml_file_associations
      puts "\n\nassociating #{self.otml_files.length} otml_files with otrunk_imports and otrunk_view_entries: "
      self.otml_files.in_groups_of(72, false).each do |otfile_group|
        otfile_group.each do |otfile|
          print 'o'; STDOUT.flush
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
        puts
      end
    end

    def create_otml_category_associations
      puts "\n\nassociating #{OtrunkExample::OtmlCategory.count} otml_categories with otrunk_imports: "
      OtrunkExample::OtmlCategory.find_in_batches(:batch_size => 72) do |category_group|
        category_group.each do |category|
          print 'o'; STDOUT.flush
          imports = category.otml_files.collect { |ot_file| ot_file.otrunk_imports }.flatten.uniq
          imports.each do |import|
            unless category.otrunk_imports.exists?(import)
              category.otrunk_imports << import
            end
          end
        end
        puts
      end
    end
    
  end
end
