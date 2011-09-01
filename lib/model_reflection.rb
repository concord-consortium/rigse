module ModelReflection
  
  #
  # returns an array of classes that inherit from ActiveRecord::Base
  #
  def find_models(klass=ActiveRecord::Base)
    Dir.chdir(File.join(::Rails.root.to_s, 'app', 'models')) do
      model_names = Dir.glob('*.rb').collect { |rb| rb[/(.*).rb/, 1].camelize } - %w{SunflowerModel SunflowerMystriUser}
      models = model_names.collect  { |m| m.constantize }
      if klass
        models.find_all { |model| model.ancestors.find { |klass| klass == ActiveRecord::Base } }
      else
        models
      end
    end
  end

  #
  # returns an array of classes that have a has_many 
  # association to Pages through PageElements
  #
  def embeddable_models
    find_models.find_all do |m| 
      m.reflect_on_all_associations(:has_many).find do  |assoc| 
        assoc.name == :pages && 
        assoc.macro == :has_many && 
        assoc.options[:through] == :page_elements
      end
    end
  end
end