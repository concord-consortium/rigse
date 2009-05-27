# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

# AASM code provided by Ana Nelson (http://ananelson.com/)

# Diagram for Acts As State Machine
class AasmDiagram < AppDiagram

  def initialize(options)
    #options.exclude.map! {|e| e = "app/models/" + e}
    super options 
    @graph.diagram_type = 'Models'
    # Processed habtm associations
    @habtm = []
  end

  # Process model files
  def generate
    STDERR.print "Generating AASM diagram\n" if @options.verbose
    files = Dir.glob("app/models/*.rb") 
    files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
    files -= @options.exclude
    files.each do |f| 
      process_class extract_class_name('app/models/', f).constantize
    end
  end
  
private
  
  # Load model classes
  def load_classes
    begin
      disable_stdout
      files = Dir.glob("app/models/**/*.rb")
      files += Dir.glob("vendor/plugins/**/app/models/*.rb") if @options.plugins_models
      files -= @options.exclude                  
      files.each {|file| get_model_class(file) }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "model classes"
      raise
    end
  end  # load_classes

  # This method is taken from the annotate models gem
  # http://github.com/ctran/annotate_models/tree/master
  #
  # Retrieve the classes belonging to the model names we're asked to process
  # Check for namespaced models in subdirectories as well as models
  # in subdirectories without namespacing.
  def get_model_class(file)
    model = file.sub(/^.*app\/models\//, '').sub(/\.rb$/, '').camelize
    parts = model.split('::')
    begin
      parts.inject(Object) {|klass, part| klass.const_get(part) }
    rescue LoadError
      Object.const_get(parts.last)
    end
  end

  # Process a model class
  def process_class(current_class)
    
    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose

    states = nil
    if current_class.respond_to? 'states'
      states  = current_class.states
      initial = current_class.initial_state
      events  = current_class.read_inheritable_attribute(:transition_table)
    elsif current_class.respond_to? 'aasm_states'
      states  = current_class.aasm_states.map { |s| s.name }
      initial = current_class.aasm_initial_state
      events  = current_class.aasm_events
    end

    # Only interested in acts_as_state_machine models.
    return if states.nil? || states.empty?

    node_attribs = []
    node_type = 'aasm'

    states.each do |state_name|
      node_shape = (initial === state_name) ? ", peripheries = 2" : ""
      node_attribs << "#{current_class.name.downcase}_#{state_name} [label=#{state_name} #{node_shape}];"
    end
    @graph.add_node [node_type, current_class.name, node_attribs]
    
    events.each do |event_name, event|
      if !event.respond_to?('each')
        def event.each(&blk)
          @transitions.each { |t| blk.call(t) }
        end
      end
      event.each do |transition|
        @graph.add_edge [
          'event', 
          current_class.name.downcase + "_" + transition.from.to_s, 
          current_class.name.downcase + "_" + transition.to.to_s, 
          event_name.to_s
        ]
      end
    end
  end # process_class

end # class AasmDiagram
