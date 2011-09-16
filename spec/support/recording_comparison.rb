
class RecordingComparison
  attr_accessor :name
  attr_accessor :recorded_object
  attr_accessor :storage_location

  def initialize(_obj, _name = "untitled")
    self.name = _name
    self.recorded_object = _obj
    self.storage_location = Rails.root.join('features','recorded_objects')
  end

  def filename_for_recording
    recorded_object_name  = recorded_object.class.name.underscore.gsub("::","__").gsub("/","__")
    recorded_object_name << name.gsub(/\s+/,"_")
    recorded_object_name << ".yml"
    return File.join(storage_location, recorded_object_name)
  end

  def record_data
    if File.exists?(filename_for_recording)
      puts "Recording for #{ recorded_object.class.name } : #{name} exists. delete #{filename_for_recording} to force new recording"
    else
      File.open(filename_for_recording, "w") do |out|
        out.write(dump_with_predictable_ids)
      end
    end
  end

  def load_data
    serialized = nil
    File.open(filename_for_recording) {|f| serialized = f.read}
    serialized
  end

  def dump_with_predictable_ids
    dumped_object = YAML.dump(recorded_object)
    predictable_yaml_ids(dumped_object)
  end

  def predictable_yaml_ids(string)
    returnv = ""
    replacements = {}
    counter = 0
    yaml_alias_regex  = /(\*|\&)(\w+)/
    returnv << string.gsub(yaml_alias_regex) do
      unless replacements[$2]
        counter = counter + 1
        replacements[$2] = counter
      end
    end
    returnv
  end

  def should_match_recorded
    load_data.should == dump_with_predictable_ids
  end

end
