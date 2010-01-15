#!/usr/bin/env ruby
#
# em.rb
#
# used for the embeddable refactoring Jan 15, 2010
#
# Example (use irb, NOT script/console):
#
# Copy em.rb to the top-level directory if you are developing with it.
# Running ModelCollection#undo will erase changes you make in config/refactoring/em.rb
# When it is working right copy the new working version back to: config/refactoring/em.rb
#
#   $ cp config/refactoring/em.rb em.rb
#   $ irb
#   >>  mc= nil;  load 'config/refactoring/em.rb'
#   >>  mc = ModelCollection.new; mc.process; nil
#
# You'll need to edit config/routes.rb by hand.
#
# Test the app, if it isn't working right yet revserse the changes:
#
#   >> mc.undo
#
# leave irb open while you might want tu run mc.undo.
#
require 'fileutils'
require 'active_record'
require 'active_support'
require 'yaml'
require 'erb'

class ModelCollection

  module NameConversion
    
    def camelize(path)
      path[/\/*(.*?)\/*$/, 1].split('/').collect { |str| 
        str[/_*(.*?)_*$/, 1].split('_').collect { |name|
           name.capitalize
        }.join
      }.join('::')
    end

    def underscore_path(path)
      path[/\/*(.*?)\/*$/, 1].gsub('/', '_')
    end

  end
  
  class SourceFile
    include NameConversion
    
    attr_accessor :source
    
    def initialize(path)
      @original_path = path
      @source = File.read(@original_path)
    end
    
    def gsub!(pairs, suffix='')
      replacement_pairs = pairs.dup
      replacement_pairs.flatten!
      0.step(replacement_pairs.length-1, 2) do |index|
        @source.gsub!(/([^A-Za-z0-9_:])#{replacement_pairs[index+0]}#{suffix}/, '\1' + replacement_pairs[index+1] + suffix )
      end
    end
    
    def insert_after_first_line(new_content)
      source.insert(source.index("\n"), new_content)
    end
    
    def convert_model_associations(model_pairs)
      @source.gsub!(/(belongs_to|has_and_belongs_to_many|has_many|has_one)\s+(:\w+)(.*?)(,*)/) do |line|
        assoc = $1
        model = $2[1..-1]
        camel_model = model[-1..-1] == 's' ? camelize($2[1..-2]) : camelize($2[1..-1])
        options = $3
        comma_suffix = $4
        clazz = ''
        if model_pair = model_pairs.detect { |mp| mp[0].split('::').last == camel_model }
          clazz = ", :class_name => '#{model_pair[1]}'"
        elsif model_pair = model_pairs.detect { |mp| mp[0].split('::').last == options[/:class_name\s+=>\s+\"(\w+)/, 1] }
          options.gsub!(model_pair[0], model_pair[1])
        end
        "#{assoc} :#{model}#{options}#{clazz}#{comma_suffix}"
      end
    end
    
    def convert_tables_names_in_finder_sql(table_name_pairs)
      replacement_table_name_pairs = table_name_pairs.dup
      replacement_table_name_pairs.flatten!
      @source.gsub!(/:finder_sql\s*\=>\s*'(.*?)'/m) do |match|
        finder_sql = $1
        0.step(replacement_table_name_pairs.length-1, 2) do |index|
          finder_sql.gsub!(replacement_table_name_pairs[index+0], replacement_table_name_pairs[index+1])
        end
        ":finder_sql => '#{finder_sql}'"
      end
    end
    
    def convert_render_partial_paths(table_name_pairs)
      replacement_pairs = table_name_pairs.dup
      replacement_pairs.flatten!
      0.step(replacement_pairs.length-1, 2) do |index|
        @source.gsub!(/\=\s*render\s+:partial\s*=>\s*(['"])#{replacement_pairs[index]}/, '= render :partial => ' + '\1' + replacement_pairs[index+1])
      end
    end
    
    def write
      File.open(@original_path, 'w') { |f| f.write @source }
    end
    
    def write_new(new_path)
      FileUtils.mkdir_p(File.dirname(new_path))
      File.open(new_path, 'w') { |f| f.write @source }
    end

    def delete_original
      FileUtils.rm_f(@original_path)
      dir = File.dirname(@original_path)
      if Dir["#{dir}/*"].length == 0
        FileUtils.rm_rf(dir)
      end
    end

  end

  class View
    def initialize(path, underscore_model_name, new_scope)
      @src = SourceFile.new(path)
      @underscore_model_name = underscore_model_name
      @new_scope = new_scope
      @view_basename = File.basename(path)
      @view_path = path[/views\/(.*)/, 1]
    end

    def original_partial_view_path
      "#{@underscore_model_name}s"
    end

    def new_partial_view_path
      "#{@new_scope}/#{@underscore_model_name}s"
    end

    def original_views_path
      "app/views/#{original_partial_view_path}"
    end

    def new_views_path
      "app/views/#{new_partial_view_path}"
    end
    
    def convert(all_model_pairs, all_table_name_pairs)
      @src.gsub!(all_model_pairs, '.')
      @src.convert_render_partial_paths(all_table_name_pairs)
      @src.write_new("#{new_views_path}/#{File.basename(@view_path)}")
    end
    
    
    def delete_original
      @src.delete_original
    end
  end
  
  class ModelProcessor
    include NameConversion
    
    attr_reader :new_model_class, :original_model_class, :original_model_symbol, 
                :original_table_name, :new_table_name, 
                :model_source, :underscore_model_name

    def initialize(model_path, new_scope)
      @current_path = Dir.pwd
      @new_scope = new_scope
      @underscore_model_name = model_path[/app\/models\/(.*).rb/, 1]
      
      @original_model_path = "app/models/#{@underscore_model_name}.rb"
      @original_model_symbol = ":#{@underscore_model_name}"
      
      @new_model_path = "app/models/#{@new_scope}/#{@underscore_model_name}.rb"
      @model_source = SourceFile.new(@original_model_path)
      @original_model_class = @model_source.source[/class\s(\S*)\s?<\s?ActiveRecord::Base/, 1]
      @new_model_class = "#{camelize(@new_scope)}::#{@original_model_class}"
      @original_table_name = parse_table_name || ActiveSupport::Inflector.pluralize(@underscore_model_name)
      @new_table_name = "#{underscore_path(@new_scope)}_#{@original_table_name}"
      @already_scoped = @underscore_model_name[/\//]

      @original_controller_path = "app/controllers/#{@underscore_model_name}s_controller.rb"
      if File.exists?(@original_controller_path)
        @new_controller_path = "app/controllers/#{@new_scope}/#{@underscore_model_name}s_controller.rb"
        @controller_source = SourceFile.new(@original_controller_path)
        @original_controller_class = @controller_source.source[/class\s(\S*)\s?<\s?ApplicationController/, 1]
        @new_controller_class = "#{camelize(@new_scope)}::#{@original_controller_class}"
      end

      @original_helper_path = "app/helpers/#{@underscore_model_name}_helper.rb"
      if File.exists?(@original_helper_path)
        @new_helper_path = "app/helpers/#{@new_scope}/#{@underscore_model_name}_helper.rb"
        @helper_source = SourceFile.new(@original_helper_path)
        @original_helper_module = @helper_source.source[/module\s+(\S*)/, 1]
        @new_helper_module = "#{camelize(@new_scope)}::#{@original_helper_module}"
      end

      @original_layout_path = "app/views/layouts/#{@underscore_model_name}.otml.haml"
      if File.exists?(@original_layout_path)
        @new_layout_path = "app/views/layouts/#{@new_scope}/#{@underscore_model_name}.otml.haml"
        @layout_source = SourceFile.new(@original_layout_path) 
      end

      @views = Dir["app/views/#{@underscore_model_name}s/**/*"].collect { |path| View.new(path, @underscore_model_name, @new_scope) }
    end

    def parse_table_name
      @model_source.source[/set_table_name\s*\"(\w+)/, 1]
    end

    def convert_model(all_model_pairs)
      @model_source.gsub!([@original_model_class, @new_model_class])
      @model_source.gsub!([/^\s*set_table_name\s+.*/, ''])
      @model_source.gsub!(['< ActiveRecord::Base', "< ActiveRecord::Base\n  set_table_name \"#{@new_table_name}\"\n"])
      @model_source.convert_model_associations(all_model_pairs)
      @model_source.write_new(@new_model_path)
    end

    def convert_database_table_name
      connection = ActiveRecord::Base.connection
      connection.rename_table(@original_table_name, @new_table_name)
    end
    
    def restore_original_database_table_name
      connection = ActiveRecord::Base.connection
      connection.rename_table(@new_table_name, @original_table_name)
    end
    
    def update_controller_comments
      original_comments = /#\s+(\w+)\s+\/(.*)/
      @controller_source.source.gsub!(original_comments) { |m| "# #{$1} /#{camelize(@new_scope)}/#{$2}" }
    end
  
    def convert_controller(all_model_pairs)
      if @controller_source
        @controller_source.gsub!([@original_controller_class, @new_controller_class])
        @controller_source.gsub!(all_model_pairs, '.')
        update_controller_comments
        @controller_source.write_new(@new_controller_path)
      end
    end

    def convert_helper(all_model_pairs)
      if @helper_source
        @helper_source.gsub!([@original_helper_module, @new_helper_module])
        @helper_source.gsub!(all_model_pairs, '.')
        @helper_source.write_new(@new_helper_path)
      end
    end

    def convert_layout(all_model_pairs)
      if @layout_source
        @layout_source.gsub!(all_model_pairs, '.')
        @layout_source.write_new(@new_layout_path)
      end
    end
    
    def convert_views(all_model_pairs)
      partial_path_pairs = @views.collect { |v| [v.original_partial_view_path, v.new_partial_view_path] }
      @views.each { |v| v.convert(all_model_pairs, partial_path_pairs) }
    end
    
    def delete_original_model
      @model_source.delete_original
    end
    
    def delete_original_controller
      if @controller_source
        @controller_source.delete_original      
      end
    end
    
    def delete_original_helper
      if @helper_source
        @helper_source.delete_original if @helper_source
      end
    end

    def delete_original_layout
      if @layout_source
        @layout_source.delete_original if @layout_source
      end
    end
    
    def delete_original_views
      @views.each { |v| v.delete_original }
    end
    
    def delete_originals
      delete_original_model
      delete_original_controller
      delete_original_helper
      delete_original_layout
      delete_original_views
    end
  end
  
  attr_reader :models
  
  def initialize
    @connection = ActiveRecord::Base.connection
    
    @new_scope_names = %w{embeddable ri_gse probe}
    clean_and_create_new_scoped_dirs

    # embeddable
    @embeddable_models = %w{data_collector data_table drawing_tool inner_page inner_page_page
      lab_book_snapshot multiple_choice multiple_choice_choice mw_modeler_page n_logo_model open_response 
      raw_otml smartgraph/range_question xhtml}
    @models = @embeddable_models.collect { |m| ModelProcessor.new("app/models/#{m}.rb", 'embeddable') }

    # embeddable/biologica
    @embeddable_biologica_models = %w{biologica_breed_offspring biologica_chromosome 
      biologica_chromosome_zoom biologica_meiosis_view biologica_multiple_organism 
      biologica_organism biologica_pedigree biologica_static_organism biologica_world}
    @models += @embeddable_biologica_models.collect { |m| ModelProcessor.new("app/models/#{m}.rb", 'embeddable/biologica') }

    # probe
    @probe_models = %w{calibration data_filter device_config physical_unit probe_type vendor_interface}
    @models += @probe_models.collect { |m| ModelProcessor.new("app/models/#{m}.rb", 'probe') }

    # ri_gse
    @gse_models = %w{assessment_target assessment_target_unifying_theme 
      big_idea domain expectation expectation_indicator expectation_stem 
      grade_span_expectation knowledge_statement unifying_theme}
    @models += @gse_models.collect { |m| ModelProcessor.new("app/models/#{m}.rb", 'ri_gse') }

    @all_model_pairs = @models.collect { |m| [m.original_model_class, m.new_model_class] }
    @all_table_name_pairs = @models.collect { |m| [m.original_table_name, m.new_table_name] }
    
    # table names that back models that belong_to :embeddable, :polymorphic => true
    @treats_embeddables_as_polymorphic = %w{page_element}
  end
  
  def generate_new_routing_scopes
    routes = ModelCollection::SourceFile.new('config/routes.rb')
    new_routing_scopes = <<-HEREDOC

#
# ********* New scoped routing for page-embeddables, probes, and RI GSEs  *********
#
#            delete the older routes by hand!
#


  map.namespace(:probe) do |probe|
    probe.resources :vendor_interfaces
    probe.resources :probe_types
    probe.resources :physical_units
    probe.resources :device_configs
    probe.resources :data_filters
    probe.resources :calibrations
  end

  map.namespace(:ri_gse) do |ri_gse|
    ri_gse.resources :assessment_targets, :knowledge_statements, :domains
    ri_gse.resources :big_ideas, :unifying_themes, :expectations, :expectation_stems
    ri_gse.resources :grade_span_expectations, 
      :collection => { 
        :select_js => :post,
        :summary => :post,
        :reparse_gses => :put,
        :select => :get }, 
      :member => { :print => :get }
  end

  map.namespace(:embeddable) do |embeddable|

    embeddable.namespace(:smartgraph) do |smartgraph|
      smartgraph.resources :range_questions
    end

    embeddable.namespace(:biologica) do |biologica|
      biologica.resources :biologica_chromosome_zooms, :member => { :destroy => :post }
      biologica.resources :biologica_multiple_organisms, :member => { :destroy => :post }
      biologica.resources :biologica_breed_offsprings, :member => { :destroy => :post }
      biologica.resources :biologica_meiosis_views, :member => { :destroy => :post }
      biologica.resources :biologica_chromosomes, :member => { :destroy => :post }
      biologica.resources :biologica_pedigrees, :member => { :destroy => :post }
      biologica.resources :biologica_static_organisms, :member => { :destroy => :post }
      biologica.resources :biologica_organisms, :member => { :destroy => :post }
      biologica.resources :biologica_worlds, :member => { :destroy => :post }
    end

    embeddable.resources :inner_pages, :member => {
      :destroy => :post,
      :add_page => :post,
      :add_element => :post,
      :set_page => :post,
      :sort_pages => :post, 
      :delete_page => :post
    }

    embeddable.resources :lab_book_snapshots, :member => { :destroy => :post }

    embeddable.resources :raw_otmls, :member => { :destroy => :post }

    embeddable.resources :n_logo_models, :member => { :destroy => :post }
    embeddable.resources :mw_modeler_pages, :member => { :destroy => :post }

    embeddable.resources :data_tables, :member => {
      :print => :get,
      :destroy => :post,
      :update_cell_data => :post
    }

    embeddable.resources :multiple_choices, :member => {
      :print => :get,
      :destroy => :post,
      :add_choice => :post
    }

    embeddable.resources :drawing_tools, :member => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :xhtmls, :member => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :open_responses, :member  => {
      :print => :get,
      :destroy => :post
    }

    embeddable.resources :data_collectors, :member => {
      :print => :get,
      :destroy => :post,
      :change_probe_type => :put
    }
  end

# ********* end of scoped routing for page-embeddables, probes, and RI GSEs  *********
    HEREDOC
    routes.insert_after_first_line(new_routing_scopes)
    routes.write
  end
  
  
  def delete_new_scoped_dirs
    @new_scope_names.each do |new_scope|
      %w{app/models app/controllers app/helpers app/views app/views/layouts}.each do |dir|
        path = "#{dir}/#{new_scope}"
        FileUtils.rm_rf(path)
      end
    end
  end
  
  def create_new_scoped_dirs
    @new_scope_names.each do |new_scope|
      %w{app/models app/controllers app/helpers app/views app/views/layouts}.each do |dir|
        path = "#{dir}/#{new_scope}"
        FileUtils.mkdir_p(path)
      end
    end
  end
  
  def clean_and_create_new_scoped_dirs
    delete_new_scoped_dirs
    create_new_scoped_dirs
  end

  def delete_originals
    @models.each { |embeddable| embeddable.delete_originals }
  end
  
  def restore_original_database_table_names
    @models.each do |model|
      model.restore_original_database_table_name
    end
  end

  def update_table_column_attributes(table, column_name, current_value, new_value)
    sql = "UPDATE `#{table}` SET `#{column_name}`='#{new_value}' WHERE `#{column_name}` = '#{current_value}';"
    updated_rows = @connection.update(sql)
    puts "updated #{updated_rows} #{current_value} #{column_name}s in #{table} to #{new_value}" if updated_rows > 0
  end
  
  def convert_embeddable_type_attributes_in_page_elements_table
    replacement_pairs = @all_model_pairs.dup
    replacement_pairs.flatten!
    0.step(replacement_pairs.length-1, 2) do |index|
      updated_rows = update_table_column_attributes('page_elements', 'embeddable_type', replacement_pairs[index], replacement_pairs[index+1])
    end
  end

  def restore_embeddable_type_attributes_in_page_elements_table
    replacement_pairs = @all_model_pairs.dup
    replacement_pairs.flatten!
    0.step(replacement_pairs.length-1, 2) do |index|
      update_table_column_attributes('page_elements', 'embeddable_type', replacement_pairs[index+1], replacement_pairs[index])
    end
  end
  
  def undo
    restore_original_database_table_names
    restore_embeddable_type_attributes_in_page_elements_table
    delete_new_scoped_dirs
    `git co app/ lib/ config/ db/migrate/`
  end
  
  def generate_migration
    timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    @migration_filename ||= "#{timestamp}_embeddable_refactoring.rb"
    @migration_path = File.join('db', 'migrate', @migration_filename)

    table_pairs = @all_table_name_pairs.collect { |p| sprintf("    %-36s%-0s", p[0], p[1]) }.join("\n")
    model_pairs = @all_model_pairs.collect      { |p| sprintf("    %-36s%-0s", p[0], p[1]) }.join("\n")
    
    table_rename_up   = @all_table_name_pairs.collect { |p| "    rename_table :#{p[0]}, :#{p[1]}" }.join("\n")
    table_rename_down = @all_table_name_pairs.collect { |p| "    rename_table :#{p[1]}, :#{p[0]}" }.join("\n")
    
    embeddable_type_up   = %q/"UPDATE `page_elements` SET `embeddable_type`='#{model_pair[1]}' WHERE `embeddable_type` = '#{model_pair[0]}';"/
    embeddable_type_down = %q/"UPDATE `page_elements` SET `embeddable_type`='#{model_pair[0]}' WHERE `embeddable_type` = '#{model_pair[1]}';"/
    
    migration = <<-HEREDOC
class EmbeddableRefactoring < ActiveRecord::Migration
  @@all_table_pairs = %w{
#{table_pairs}
  }
  @@all_model_pairs = %w{
#{model_pairs}
  }

  def self.up
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[0], table_pair[1]
    end
    @@all_model_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update(#{embeddable_type_up})
    end
  end

  def self.down
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[1], table_pair[0]
    end
    @@all_model_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update(#{embeddable_type_down})
    end
  end
end
    HEREDOC
    File.open(@migration_path, 'w') { |f| f.write migration }
  end
  
  def process
    @models.each do |model|
      model.convert_model(@all_model_pairs)
      model.convert_database_table_name
      model.convert_controller(@all_model_pairs)
      model.convert_helper(@all_model_pairs)
      model.convert_layout(@all_model_pairs)
      model.convert_views(@all_model_pairs)
    end
    Dir["config/**/*.{rb,rake}"].each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_pairs)
      source.write
    end
    Dir["lib/**/*.{rb,rake}"].each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_pairs)
      source.write
    end
    (Dir["app/controllers/**/*.rb"] - Dir["app/controllers/{#{@new_scope_names.join(',')}}/**/*"]).each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_pairs)
      source.write
    end
    (Dir["app/models/**/*.rb"] - Dir["app/models/{#{@new_scope_names.join(',')}}/**/*"]).each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_pairs)
      source.convert_model_associations(@all_model_pairs)
      source.convert_tables_names_in_finder_sql(@all_table_name_pairs)
      source.write
    end
    convert_embeddable_type_attributes_in_page_elements_table
    delete_originals
    generate_new_routing_scopes  # existing routes will need to be moved to the new name-scoped route blocks
  end
end

ActiveRecord::Base.establish_connection(YAML::load(ERB.new(File.read("config/database.yml")).result)['development'])

# mc = nil; load 'em.rb'
# mc = ModelCollection.new; mc.process; nil
# fix config/routes.rb and test
# problems ...?
# mc.undo
# when it works ...
# mc.generate_migration
