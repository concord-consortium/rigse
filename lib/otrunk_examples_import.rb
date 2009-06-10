class OtrunkExampleImport
  require 'hpricot'
  require 'open-uri'
  require 'fileutils'

  require 'set'
  require 'arrayfields'

  ViewEntry = Array.struct :fq_view_classname, :fq_object_classname

  class OtFile
    attr_accessor :path, :name, :category, :last_modified, :body, :doc, :imports, :view_entries
    def initialize(path)
      @path = path
      @name = File.basename(path)
      @category =  File.basename(File.dirname(@path))
      @last_modified =  File.ctime(@path)
      @body = File.read(path)
      @doc = Hpricot::XML(@body)
      @imports = @doc.search("import").collect { |e| e['class'] }
      @view_entries = @doc.search("OTViewEntry").collect {|ve| ViewEntry.new([ve['viewClass'], ve['objectClass']])}
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
    attr_accessor :path, :name, :body, :doc, :launch_type, :project_name, :projects_dir, :class_dir, :category,
                  :projects, :internal_archives, :main_type, :program_arguments, :vm_arguments, :valid
    def initialize(path)
      @path = path
      @name = File.basename(@path).chomp('.launch')
      @body = File.read(@path)
      @doc = Hpricot::XML(@body)
      @launch_type = @doc.search("launchConfiguration").attr(:type).split('.')[-1]
      list_entry_values = @doc.search("listAttribute[@key='org.eclipse.jdt.launching.CLASSPATH']/listEntry").collect {|le| le['value']}
      @project_name = @doc.search("stringAttribute[@key='org.eclipse.jdt.launching.PROJECT_ATTR']").attr(:value)
      @projects_dir = @path.split(project_name)[0]
      @category = @path[/#{@project_name}\/(.*)\//, 1]
      @internal_archives = []
      @projects = []
      @valid = true
      list_entry_values.each do |val|
        value = Hpricot::XML(val)
        if project = value.search("runtimeClasspathEntry")[0]['projectName']
          path = @projects_dir + project
          if File.exists?("#{path}/.classpath")
            classpath = Hpricot.XML(open("#{path}/.classpath"))
            output = classpath.at("classpathentry[@kind=output]")['path']
            @projects <<  "#{path}/#{output}"
          else
            @valid = false
            @projects <<  "#{path}/no-classpath-found"
          end
        elsif archive = value.search("runtimeClasspathEntry")[0]['internalArchive']
          @internal_archives << @projects_dir.chomp('/') + archive
        end
      end
      @main_type = @doc.search("stringAttribute[@key='org.eclipse.jdt.launching.MAIN_TYPE']").collect {|i| i['value']}.to_s
      @program_arguments = @doc.search("stringAttribute[@key='org.eclipse.jdt.launching.PROGRAM_ARGUMENTS']").collect {|i| i['value']}.to_s
      @vm_arguments = @doc.search("stringAttribute[@key='org.eclipse.jdt.launching.VM_ARGUMENTS']").collect {|i| i['value']}.to_s
    end
  end

  class OtIntrospect
    attr_accessor :otml_files, :otml_imports, :otml_view_entries, :otml_launch_files, :imports, 
                  :view_entries, :projects, :internal_archives, :categories
    def initialize(dir='.')
      @otml_files, @otml_imports, @otml_view_entries, @otml_launch_files  = [], [], [], []
      @imports, @view_entries, @projects, @internal_archives, @categories = [], [], [], [], []
      files = Dir["#{dir}/**/*.launch"]
      files.each do |f|
        @otml_launch_files << OtLaunchFile.new(f)
        @projects += (@otml_launch_files[-1].projects || [])
        @internal_archives += (@otml_launch_files[-1].internal_archives || [])
        @categories += [@otml_launch_files[-1].category]
      end
      @projects.uniq!
      @internal_archives.uniq!
      files = Dir["#{dir}/**/*.otml"]
      files.each do |f|
        @otml_files << OtFile.new(f)
        @imports += @otml_files[-1].imports
        @view_entries += @otml_files[-1].view_entries
        @categories += [@otml_files[-1].category]
      end
      @imports.uniq!
      @view_entries.uniq!
      @categories.uniq!
      @imports.each do |import|
        @otml_imports << OtImport.new(import, @otml_files.reject {|f| (f.imports & [import]).empty?})
      end
      @view_entries.each do |ve|
        @otml_view_entries << OtViewEntry.new(ve, @otml_files.reject {|f| (f.view_entries & @view_entries).empty?})
      end

      artifact_types = %w{otml_files otml_imports otml_view_entries otml_launch_files projects internal_archives}
      artifact_types.each { |artifact_type| puts sprintf("%-20s %-s", "#{artifact_type}:", "#{self.send(artifact_type).length}") }
    end
  end
end
