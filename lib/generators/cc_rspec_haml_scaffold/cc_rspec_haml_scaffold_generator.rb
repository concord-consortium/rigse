class CcRspecHamlScaffoldGenerator < RspecScaffoldGenerator

  def initialize(runtime_args, runtime_options = {})
    super
  end

  def manifest
    # get rspec-rails version of a scaffold manifest
    rspec_manifest = super
    # remove the template actions that generate erb views
    rspec_manifest.actions.delete_if { |action| action[0] == :template && action[1][1][/app\/views/] }
    # remove the generation of 'scaffold.css'
    rspec_manifest.actions.delete_if { |action| action[1][1] == 'public/stylesheets/scaffold.css' }
    # add haml versions of the basic view actions
    %w{index show new edit}.each do |action|
      rspec_manifest.template("cc_rspec_haml_scaffold:view_#{action}.haml.erb", 
        File.join('app/views', controller_class_path, controller_file_name, "#{action}.html.haml")
      )
    end
    # return the modified manifest
    rspec_manifest
  end
  
  protected
  
  # The following two methods the view templates were copied from
  # http://github.com/dfischer/rspec-haml-scaffold-generator/tree
  # The code in dfischer/rspec-haml-scaffold-generator is distributed under a BSD-type license:
  # http://github.com/dfischer/rspec-haml-scaffold-generator/blob/ef61617ea440575d00077e24539f5105f5692a53/LICENSE
  
  def form_link_for(table_name, singular_name)
    if !@controller_name.split("/")[1].nil?
      return "[:#{@controller_class_nesting.downcase}, @#{singular_name.singularize}]"  
    else
      return "@#{singular_name.singularize}"
    end    
  end
  
  def path_for(singular, plural, txt)
    case txt
    when "show"
      return "#{table_name.singularize}_path(@#{singular_name.singularize})"
    when "edit"
      return "edit_#{table_name.singularize}_path(@#{singular_name.singularize})"
    when "destroy"
      return "#{table_name.singularize}_path(@#{singular_name.singularize}), :confirm => 'Are you sure?', :method => :delete"
    when "index"  
      return "#{table_name}_path"
    end  
  end
  
end
