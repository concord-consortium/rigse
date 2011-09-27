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
# require 'oniguruma'

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
    
    def singularize(str)
      str[/(.*?)(s?$)/, 1]
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
    
    # Examples of model associations that need processing
    #
    # belongs_to :probe_type
    #
    # belongs_to :probe_type, :class_name => 'ProbeType'
    # 
    # has_many :page_elements,
    #   :finder_sql => 'SELECT page_elements.* FROM page_elements
    #   INNER JOIN pages ON page_elements.page_id = pages.id 
    #   INNER JOIN sections ON pages.section_id = sections.id
    #   INNER JOIN activities ON sections.activity_id = activities.id
    #   WHERE activities.investigation_id = #{id}'
    # 
    # [:grade_span, :domain].each { |m| delegate m, :to => :grade_span_expectation }
    # 
    # scope :with_gse, {
    #   :joins => "left outer JOIN grade_span_expectations on (grade_span_expectations.id = investigations.grade_span_expectation_id) 
    #      JOIN assessment_targets ON (assessment_targets.id = grade_span_expectations.assessment_target_id) 
    #      JOIN knowledge_statements ON (knowledge_statements.id = assessment_targets.knowledge_statement_id)"
    # }
    # 
    # scope :domain, lambda { |domain_id| 
    #   {
    #     :conditions =>[ 'knowledge_statements.domain_id = ?', domain_id]
    #   }
    # }
    
    def convert_model_associations(model_pairs)
      @source.gsub!(/(belongs_to|has_and_belongs_to_many|has_many|has_one)\s+(:\w+)(.*)/) do |match|
        assoc = $1
        model = $2[1..-1]
        options = $3
        # comma_suffix = options[-1..-1] == ','
        comma_suffix = ''
        options_classname = options[/:class_name\s*\=>\s*['"](.*)['"]/, 1]
        camel_model = options_classname || (model[-1..-1] == 's' ? camelize(model[0..-2]) : camelize(model[0..-1]))
        clazz = ''
        if model_pair = model_pairs.detect { |mp| mp[0].split('::').last == camel_model }
          if options_classname
            options.gsub!(model_pair[0], model_pair[1])
            result = "#{assoc} :#{model}#{options}"
          else
            clazz = ", :class_name => '#{model_pair[1]}'"
            result = "#{assoc} :#{model}#{clazz}#{options}"
          end
        else
          result = match
        end
        # puts sprintf("%-40s%-80s%-40s%-40s", "model: #{model}", "options_classname: #{options_classname}", "camel_model: #{camel_model}", result)
        result
      end
    end
    
    def convert_table_names_in_finder_sql(table_name_pairs)
      replacement_table_name_pairs = table_name_pairs.dup
      replacement_table_name_pairs.flatten!
      @source.gsub!(/:finder_sql\s*\=>\s*'(.*?)'/m) do |match|
        finder_sql = $1
        0.step(replacement_table_name_pairs.length-1, 2) do |index|
          finder_sql.gsub!(/\s+#{replacement_table_name_pairs[index+0]}/, " #{replacement_table_name_pairs[index+1]}")
        end
        ":finder_sql => '#{finder_sql}'"
      end
    end
    
    def convert_table_names_in_joins(table_name_pairs)
      replacement_table_name_pairs = table_name_pairs.dup
      replacement_table_name_pairs.flatten!
      @source.gsub!(/:joins\s*\=>\s*('|")(.*?)\1/m) do |match|
        joins_delimiter = $1.dup
        joins_sql = $2.dup
        0.step(replacement_table_name_pairs.length-1, 2) do |index|
          joins_sql.gsub!(/(\s+|\(|\.)(#{replacement_table_name_pairs[index+0]})(\s+|\.)/) do |match|
            "#{$1}#{replacement_table_name_pairs[index+1]}#{$3}"
          end
        end
        ":joins => #{joins_delimiter}#{joins_sql}#{joins_delimiter}"
      end
    end

    def convert_table_names_in_conditions(table_name_pairs)
      replacement_table_name_pairs = table_name_pairs.dup
      replacement_table_name_pairs.flatten!
      @source.gsub!(/:conditions\s*\=>\s*\[\s*('|")(.*?)\1/m) do |match|
        conditions_delimiter = $1.dup
        conditions_sql = $2.dup
        0.step(replacement_table_name_pairs.length-1, 2) do |index|
          conditions_sql.gsub!(/(^|\s+)(#{replacement_table_name_pairs[index+0]})\./) do |match|
            "#{$1}#{replacement_table_name_pairs[index+1]}."
          end
        end
        ":conditions => [#{conditions_delimiter}#{conditions_sql}#{conditions_delimiter}"
      end
    end
    
    def convert_table_names(table_name_pairs)
      convert_table_names_in_finder_sql(table_name_pairs)
      convert_table_names_in_joins(table_name_pairs)
      convert_table_names_in_conditions(table_name_pairs)
    end
    
    def convert_partial_paths_and_routes(table_name_pairs)
      replacement_pairs = table_name_pairs.dup
      replacement_pairs.flatten!
      # puts @original_path
      0.step(replacement_pairs.length-1, 2) do |index|
        current_path = replacement_pairs[index]
        new_path = replacement_pairs[index+1]
        path_prefix = new_path[/(.*?)#{current_path}/, 1]
        current_route = underscore_path(current_path).singularize
        new_route = underscore_path(new_path).singularize
        route_prefix = new_route[/(.*?)#{current_route}/, 1]
        # puts "routes: #{current_route}, #{new_route} #{route_prefix}"
        # grade_span_expectations_path
        # ri_gse_grade_span_expectations_path
        # expectations
        # ri_gse_grade_span_ri_gse_expectations_path
        
        @source.gsub!(/\=\s*render\s+:partial\s*=>\s*(['"])#{current_path}/)      { |match| "= render :partial => #{$1}#{new_path}" }
        @source.gsub!(/(=>|,)\s*(.*)#{current_route}(s?)(_path|_url)/) do |match|
        # Oniguruma::ORegexp.new("(=>|,)\s*(.*)(?<!#{route_prefix})#{current_route}(s?)(_path|_url)").gsub!(@source) do |match|

          result = "#{$1} #{$2}#{new_route}#{$3}#{$4}"
          if match =~ /#{route_prefix}/
            final = match
          else
            final = result
          end
          # puts "#{route_prefix}: #{match} <=> #{result} ==> #{final}"
          final
        end
      end
    end

    def convert_model_classnames(model_classname_pairs)
      replacement_pairs = model_classname_pairs.dup
      replacement_pairs.flatten!
      0.step(replacement_pairs.length-1, 2) do |index|
        current_name = replacement_pairs[index]
        new_name = replacement_pairs[index+1]
        @source.gsub!(/(\(|\[|,|\s+)#{current_name}($|,|\s+|\.|\])/) { |m| "#{$1}#{new_name}#{$2}" }
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
    def initialize(path, underscore_model_name, new_underscore_model_name, new_scope)
      @src = SourceFile.new(path)
      @underscore_model_name = underscore_model_name
      @new_underscore_model_name = new_underscore_model_name
      @new_scope = new_scope
      @view_basename = File.basename(path)
      @view_path = path[/views\/(.*)/, 1]
    end

    def original_partial_view_path
      "#{@underscore_model_name}s"
    end

    def new_partial_view_path
      "#{@new_scope}/#{@new_underscore_model_name}s"
    end

    def original_views_path
      "app/views/#{original_partial_view_path}"
    end

    def new_views_path
      "app/views/#{new_partial_view_path}"
    end
    
    def convert(all_model_classname_pairs, all_table_name_pairs)
      @src.convert_model_classnames(all_model_classname_pairs)
      @src.convert_partial_paths_and_routes(all_table_name_pairs)
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
      
      @model_source = SourceFile.new(@original_model_path)
      @original_model_class = @model_source.source[/class\s(\S*)\s?<\s?ActiveRecord::Base/, 1]
      @original_table_name = parse_table_name || ActiveSupport::Inflector.pluralize(@underscore_model_name)
      @already_scoped = @underscore_model_name[/\//]

      if @new_scope =~ /biologica/
        @new_model_class = "#{camelize(@new_scope)}::#{@original_model_class[/Biologica(.*)/, 1]}"
        @new_table_name = "#{underscore_path(@new_scope)}_#{@original_table_name[/biologica_(.*)/, 1]}"
        @new_underscore_model_name = @underscore_model_name[/biologica_(.*)/, 1]
      else
        @new_model_class = "#{camelize(@new_scope)}::#{@original_model_class}"
        @new_table_name = "#{underscore_path(@new_scope)}_#{@original_table_name}"
        @new_underscore_model_name = @underscore_model_name
      end
      @new_model_path = "app/models/#{@new_scope}/#{@new_underscore_model_name}.rb"

      @original_controller_path = "app/controllers/#{@underscore_model_name}s_controller.rb"
      if File.exists?(@original_controller_path)
        @new_controller_path = "app/controllers/#{@new_scope}/#{@new_underscore_model_name}s_controller.rb"
        @controller_source = SourceFile.new(@original_controller_path)
        @original_controller_class = @controller_source.source[/class\s(\S*)\s?<\s?ApplicationController/, 1]
        @new_controller_class = "#{camelize(@new_scope)}::#{@original_controller_class}"
      end

      @original_helper_path = "app/helpers/#{@underscore_model_name}_helper.rb"
      if File.exists?(@original_helper_path)
        @new_helper_path = "app/helpers/#{@new_scope}/#{@new_underscore_model_name}_helper.rb"
        @helper_source = SourceFile.new(@original_helper_path)
        @original_helper_module = @helper_source.source[/module\s+(\S*)/, 1]
        @new_helper_module = "#{camelize(@new_scope)}::#{@original_helper_module}"
      end

      @original_layout_path = "app/views/layouts/#{@underscore_model_name}.otml.haml"
      if File.exists?(@original_layout_path)
        @new_layout_path = "app/views/layouts/#{@new_scope}/#{@new_underscore_model_name}.otml.haml"
        @layout_source = SourceFile.new(@original_layout_path) 
      end

      @views = Dir["app/views/#{@underscore_model_name}s/**/*"].collect do |path| 
        View.new(path, @underscore_model_name, @new_underscore_model_name, @new_scope)
      end.sort { |v1, v2| v2.original_partial_view_path.length <=> v1.original_partial_view_path.length }
    end

    def parse_table_name
      @model_source.source[/set_table_name\s*\"(\w+)/, 1]
    end

    def convert_model(all_model_classname_pairs)
      @model_source.gsub!([@original_model_class, @new_model_class])
      @model_source.gsub!([/^\s*set_table_name\s+.*/, ''])
      @model_source.gsub!(['< ActiveRecord::Base', "< ActiveRecord::Base\n  set_table_name \"#{@new_table_name}\"\n"])
      @model_source.convert_model_associations(all_model_classname_pairs)
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
  
    def convert_controller(all_model_classname_pairs)
      if @controller_source
        @controller_source.gsub!([@original_controller_class, @new_controller_class])
        @controller_source.gsub!(all_model_classname_pairs, '.')
        update_controller_comments
        @controller_source.write_new(@new_controller_path)
      end
    end

    def convert_helper(all_model_classname_pairs)
      if @helper_source
        @helper_source.gsub!([@original_helper_module, @new_helper_module])
        @helper_source.gsub!(all_model_classname_pairs, '.')
        @helper_source.write_new(@new_helper_path)
      end
    end

    def convert_layout(all_model_classname_pairs)
      if @layout_source
        @layout_source.gsub!(all_model_classname_pairs, '.')
        @layout_source.write_new(@new_layout_path)
      end
    end
    
    def convert_views(all_model_classname_pairs)
      partial_path_pairs = @views.collect { |v| [v.original_partial_view_path, v.new_partial_view_path] }
      @views.each { |v| v.convert(all_model_classname_pairs, partial_path_pairs) }
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
  
  attr_reader :models, :all_model_classname_pairs, :all_table_name_pairs
  def initialize
    ActiveRecord::Base.establish_connection(YAML::load(ERB.new(File.read("config/database.yml")).result)['development'])
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
    
    @models = @models.sort { |m1, m2| m2.original_table_name.length <=> m1.original_table_name.length }
    @all_model_classname_pairs = @models.collect { |m| [m.original_model_class, m.new_model_class] }
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
      biologica.resources :chromosome_zooms, :member => { :destroy => :post }
      biologica.resources :multiple_organisms, :member => { :destroy => :post }
      biologica.resources :breed_offsprings, :member => { :destroy => :post }
      biologica.resources :meiosis_views, :member => { :destroy => :post }
      biologica.resources :chromosomes, :member => { :destroy => :post }
      biologica.resources :pedigrees, :member => { :destroy => :post }
      biologica.resources :static_organisms, :member => { :destroy => :post }
      biologica.resources :organisms, :member => { :destroy => :post }
      biologica.resources :worlds, :member => { :destroy => :post }
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
    @models.each { |model| model.delete_originals }
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
    replacement_pairs = @all_model_classname_pairs.dup
    replacement_pairs.flatten!
    0.step(replacement_pairs.length-1, 2) do |index|
      updated_rows = update_table_column_attributes('page_elements', 'embeddable_type', replacement_pairs[index], replacement_pairs[index+1])
    end
  end

  def restore_embeddable_type_attributes_in_page_elements_table
    replacement_pairs = @all_model_classname_pairs.dup
    replacement_pairs.flatten!
    0.step(replacement_pairs.length-1, 2) do |index|
      update_table_column_attributes('page_elements', 'embeddable_type', replacement_pairs[index+1], replacement_pairs[index])
    end
  end
  
  def undo
    restore_original_database_table_names
    restore_embeddable_type_attributes_in_page_elements_table
    delete_new_scoped_dirs
    `git co app/ lib/ config/ db/migrate/ themes/`
  end
  
  def generate_migration
    timestamp = Time.now.gmtime.strftime('%Y%m%d%H%M%S')
    @migration_filename ||= "#{timestamp}_embeddable_refactoring.rb"
    @migration_path = File.join('db', 'migrate', @migration_filename)

    table_pairs = @all_table_name_pairs.collect { |p| sprintf("    [%-42s%-52s]", "'#{p[0]}',", "'#{p[1]}'") }.join(",\n")
    model_pairs = @all_model_classname_pairs.collect      { |p| sprintf("    [%-42s%-52s]", "'#{p[0]}',", "'#{p[1]}'") }.join(",\n")
    
    table_rename_up   = @all_table_name_pairs.collect { |p| "    rename_table :#{p[0]}, :#{p[1]}" }.join("\n")
    table_rename_down = @all_table_name_pairs.collect { |p| "    rename_table :#{p[1]}, :#{p[0]}" }.join("\n")
    
    embeddable_type_up   = %q/"UPDATE `page_elements` SET `embeddable_type`='#{model_pair[1]}' WHERE `embeddable_type` = '#{model_pair[0]}';"/
    embeddable_type_down = %q/"UPDATE `page_elements` SET `embeddable_type`='#{model_pair[0]}' WHERE `embeddable_type` = '#{model_pair[1]}';"/
    
    migration = <<-HEREDOC
class EmbeddableRefactoring < ActiveRecord::Migration
  @@all_table_pairs = [
#{table_pairs}
  ]
  @@all_model_classname_pairs = [
#{model_pairs}
  ]

  def self.up
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[0], table_pair[1]
    end
    @@all_model_classname_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update(#{embeddable_type_up})
    end
  end

  def self.down
    @@all_table_pairs.each do |table_pair|
      rename_table table_pair[1], table_pair[0]
    end
    @@all_model_classname_pairs.each do |model_pair|
      ActiveRecord::Base.connection.update(#{embeddable_type_down})
    end
  end
end
    HEREDOC
    File.open(@migration_path, 'w') { |f| f.write migration }
  end
  
  def process
    @models.each do |model|
      model.convert_model(@all_model_classname_pairs)
      model.convert_database_table_name
      model.convert_controller(@all_model_classname_pairs)
      model.convert_helper(@all_model_classname_pairs)
      model.convert_layout(@all_model_classname_pairs)
      model.convert_views(@all_model_classname_pairs)
    end
    delete_originals
    Dir["config/**/*.{rb,rake}"].each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_classname_pairs)
      source.write
    end
    Dir["lib/**/*.{rb,rake}"].each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_classname_pairs)
      source.write
    end
    (Dir["app/controllers/**/*.rb"] - Dir["app/controllers/{#{@new_scope_names.join(',')}}/**/*"]).each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_classname_pairs)
      source.write
    end
    (Dir["app/models/**/*.rb"] - Dir["app/models/{#{@new_scope_names.join(',')}}/**/*"]).each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.gsub!(@all_model_classname_pairs)
      source.convert_model_associations(@all_model_classname_pairs)
      source.convert_table_names(@all_table_name_pairs)
      source.write
    end
    Dir["app/models/{#{@new_scope_names.join(',')}}/**/*.rb"].each do |path|
      source = ModelCollection::SourceFile.new(path)
      source.convert_table_names(@all_table_name_pairs)
      source.write
    end
    views = Dir["app/views/**/*{haml,erb}"] + Dir["themes/**/*.haml"]
    views.each do |path|
      view = ModelCollection::SourceFile.new(path)
      view.convert_partial_paths_and_routes(@all_table_name_pairs)
      view.convert_model_classnames(@all_model_classname_pairs)
      view.write
    end
    # (Dir["app/views/layouts/**/*{haml,erb}"] - Dir["app/views/layouts/{#{@new_scope_names.join(',')}}/**/*"]).each do |path|
    #   view = ModelCollection::SourceFile.new(path)
    #   view.convert_partial_paths_and_routes(@all_table_name_pairs)
    #   view.convert_model_classnames(@all_model_classname_pairs)
    #   view.write
    # end
    # views = Dir["app/views/**/*{haml,erb}"] - Dir["app/views/layouts/**/*{haml,erb}"] - Dir["app/views/{#{@new_scope_names.join(',')}}/**/*{haml,erb}"]
    # views = views + Dir["themes/*/views/**/*.haml"]
    # views.each do |path|
    #   view = ModelCollection::SourceFile.new(path)
    #   view.convert_partial_paths_and_routes(@all_table_name_pairs)
    #   view.convert_model_classnames(@all_model_classname_pairs)
    #   view.write
    # end
    helpers = Dir["app/helpers/**/*.rb"] - Dir["app/helpers/{#{@new_scope_names.join(',')}}/**/*.rb"]
    helpers.each do |path|
      helper = ModelCollection::SourceFile.new(path)
      helper.convert_model_classnames(@all_model_classname_pairs)
      helper.write
    end
    convert_embeddable_type_attributes_in_page_elements_table
    generate_new_routing_scopes  # existing routes will need to be moved to the new name-scoped route blocks
  end
end



# mc = nil; load 'em.rb'
# mc = ModelCollection.new; mc.process; nil
# fix config/routes.rb and test
# problems ...?
# mc.undo
# when it works ...
# mc.generate_migration
