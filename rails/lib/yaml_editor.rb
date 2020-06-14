require 'yaml'
require 'rubygems'
require 'highline/import'

class YamlEditor
  attr_accessor :defaults
  attr_accessor :filename
  attr_accessor :properties

  def initialize(_filename, _defaults={})
    self.filename = _filename
    self.properties = YAML::load_file(_filename)
    @prop_path = []
  end
  

  def edit
    puts "Editing values in #{self.filename}"
    self.properties.each_pair do |key,value|
      self.update(key,value)
    end
  end

  def update(prop,value)
    @prop_path.push(prop)
    if value.respond_to? :each_pair
      value.each_pair do |k,v| 
        self.update(k,v)
      end
    elsif value.respond_to? :join
      default = value.join(",")
      new_value_string = ask("new value for #{@prop_path.join(':')}") { |q| q.default = default}
      value = new_value_string.split(",").map {|v| v.strip }
    else
      value = ask("new value for #{@prop_path.join(":")}" ) { |q| q.default = value }
    end
    # this never actually writes the value back to the properties!!!
    @prop_path.pop
  end

  def write_file
    File.open(self.filename, 'w') {|f| f.write self.properties.to_yaml}
  end
  

end

