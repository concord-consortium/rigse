ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  
  require 'spec/autorun'
  require 'spec/rails'
  
  # *** customizations ***
  
  require 'remarkable_rails'
  
  include AuthenticatedTestHelper
  include AuthenticatedSystem
  
  require 'factory_girl'
  @factories = Dir.glob(File.join(File.dirname(__FILE__), '../factories/*.rb'))
  
  if ActiveRecord::Migrator.new(:up, RAILS_ROOT + "/db/migrate").pending_migrations.empty?
    if Probe::ProbeType.count == 0
      puts
      puts "*** Probe configuration models need to be loaded into the test database to run the tests"
      puts "*** run: rake db:test:prepare"
      puts
      exit
    end
  else
    puts
    puts "*** pending migrations need to be applied to run the tests"
    puts "*** run: rake db:test:prepare"
    puts
    exit
  end

  Dir.glob(File.dirname(__FILE__) + "/support/*.rb").each { |f| require(f) }

  # *** end of customizations ***
  
  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  end
  
  # FIXME Somehow using webrat kills calling .id on ActiveRecord objects...
  # example, in a test:
  #    model = Embeddable::MwModelerPage.find(:first)
  #    my_id = model.id   <==== throws NoMethodError
  #    my_id = model[:id] <==== works fine
  # require "webrat"
  # Webrat.configure do |config|
  #   config.mode = :rails
  # end
    
end

Spork.each_run do
  @factories.each { |f| load f }
  
  puts "Loading default data set required for application_controller.rb to run ...."
  anon =  Factory.next :anonymous_user
  admin = Factory.next :admin_user 
  device_config = Factory.create(:probe_device_config)
  versioned_jnlp = Factory(:maven_jnlp_versioned_jnlp)
  school = Factory(:portal_school)
  domain = Factory(:rigse_domain)
  grade = Factory(:portal_grade)
  Admin::Project.create_or_update_default_project_from_settings_yml
  puts "done."
end
