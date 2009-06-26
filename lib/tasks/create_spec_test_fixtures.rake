namespace :rigse do
  namespace :test do
    
    desc "Saves users and roles to spec/fixtures" 
    task :create_fixtures => :environment do 
      dir = File.join(RAILS_ROOT, 'spec/fixtures')
      FileUtils.mkdir_p(dir)
      FileUtils.chdir(dir) do
        [User, Role].each do |klass|
          File.open("#{klass.class_name.pluralize.downcase}.yaml", 'w') do |f| 
            attributes = klass.find(:all).collect { |m| m.attributes }
            f.write YAML.dump(attributes)
          end
        end
      end
    end
  end
end
