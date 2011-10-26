# RailRoad - RoR diagrams generator
# http://railroad.rubyforge.org
#
# Copyright 2007-2008 - Javier Smaldone (http://www.smaldone.com.ar)
# See COPYING for more details

# RailRoad controllers diagram
class ControllersDiagram < AppDiagram

  def initialize(options)
    #options.exclude.map! {|e| "app/controllers/" + e}
    super options
    @graph.diagram_type = 'Controllers'
  end

  # Process controller files
  def generate
    STDERR.print "Generating controllers diagram\n" if @options.verbose

    files = Dir.glob("app/controllers/**/*_controller.rb") - @options.exclude
    files.each do |f|
      class_name = extract_class_name('app/controllers/', f)
      process_class class_name.constantize
    end
  end # generate

  private

  # Load controller classes
  def load_classes
    begin
      disable_stdout
      files = Dir.glob("app/controllers/**/*_controller.rb") - @options.exclude
      files.each {|file| get_controller_class(file) }
      enable_stdout
    rescue LoadError
      enable_stdout
      print_error "controller classes"
      raise
    end
  end # load_classes

  # This method is taken from the annotate models gem
  # http://github.com/ctran/annotate_models/tree/master
  #
  # Retrieve the classes belonging to the controller names we're asked to process
  # Check for namespaced controllers in subdirectories as well as controllers
  # in subdirectories without namespacing.
  def get_controller_class(file)
    model = file.sub(/^.*app\/controllers\//, '').sub(/\.rb$/, '').camelize
    parts = model.split('::')
    begin
      parts.inject(Object) {|klass, part| klass.const_get(part) }
    rescue LoadError
      Object.const_get(parts.last)
    end
  end

  # Proccess a controller class
  def process_class(current_class)

    STDERR.print "\tProcessing #{current_class}\n" if @options.verbose

    if @options.brief
      @graph.add_node ['controller-brief', current_class.name]
    elsif current_class.is_a? Class
      # Collect controller's methods
      node_attribs = {:public    => [],
                      :protected => [],
                      :private   => []}
      current_class.public_instance_methods(false).sort.each { |m|
        process_method(node_attribs[:public], m)
      } unless @options.hide_public
      current_class.protected_instance_methods(false).sort.each { |m|
        process_method(node_attribs[:protected], m)
      } unless @options.hide_protected
      current_class.private_instance_methods(false).sort.each { |m|
        process_method(node_attribs[:private], m)
      } unless @options.hide_private
      @graph.add_node ['controller', current_class.name, node_attribs]
    elsif @options.modules && current_class.is_a?(Module)
      @graph.add_node ['module', current_class.name]
    end

    # Generate the inheritance edge (only for ApplicationControllers)
    if @options.inheritance &&
       (ApplicationController.subclasses.include? current_class.name)
      @graph.add_edge ['is-a', current_class.superclass.name, current_class.name]
    end
  end # process_class

  # Process a method
  def process_method(attribs, method)
    return if @options.hide_underscore && method[0..0] == '_'
    attribs << method
  end

end # class ControllersDiagram
