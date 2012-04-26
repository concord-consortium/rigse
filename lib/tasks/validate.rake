
# touch all model classes, so they show up in ActiveRecord::Base.descendants
def load_all_models()
  Dir.chdir("#{Rails.root}/app/models") do
    Dir.glob(File.join('**', '*.rb')) do |filename|
      begin
        filename.sub(/\.rb$/,'').classify.constantize
      rescue Exception
        $stderr.puts "Failed to load #{filename}: #{filename.sub(/\.rb$/,'').classify}"
      end
    end
  end
end


def for_each_model_instance(find_conditions = {}, &block)
  skip = [Itsi::Itsi, Ccportal::Ccportal, Embeddable::Embeddable, ActiveRecord::SessionStore::Session]
  ar_models = ActiveRecord::Base.descendants.delete_if {|m| skip.include?(m) }.sort_by{|m| m.name }
  find_conditions.merge!({:batch_size => 5})
  ar_models.each do |model|
    begin
      print "Processing #{model.count} #{model.name.pluralize}..."
      count = 0
      model.find_each(find_conditions) do |instance|
        print("\n%6d: " % count) if count % 2000 == 0
        res = yield(model, instance)
        count += 1
        print "." if count % 50 == 0
      end
      puts " done."
    rescue Exception => ex
     $stderr.puts "Failed to process model: #{model.name}\n#{ex}\n"
    end
  end
end

namespace :app do
  namespace :validate do
    desc "Process all of the model objects and find timestamps that have nil values"
    task :fix_nil_timestamps => :environment do
      (puts "You must run this rake task in production mode!" and return) unless Rails.env.production?
      load_all_models

      for_each_model_instance(:conditions => 'created_at IS NULL OR updated_at IS NULL') do |klass, instance|
        instance.updated_at = Time.now if instance.respond_to?(:updated_at) && instance.updated_at.nil?
        instance.created_at = instance.updated_at if instance.respond_to?(:created_at) && instance.created_at.nil?
        instance.save
      end
    end

    desc "Process all of the model objects and find associations that have nil values"
    task :list_nil_associations => :environment do
      (puts "You must run this rake task in production mode!" and return) unless Rails.env.production?
      load_all_models

      OK_TO_BE_NIL = [
        [User, :portal_teacher],
        [User, :portal_student],
        [Embeddable::DataCollector, :calibration],
        [Embeddable::DataCollector, :data_table],
        [Embeddable::DataCollector, :prediction_graph_source],
        [MavenJnlp::VersionedJnlp, :icon],
        [Activity, :original],
        [Dataservice::BundleLogger, :in_progress_bundle],
        [Dataservice::BundleLogger, :last_non_empty_bundle_content],
        [Dataservice::ConsoleLogger, :last_console_content]
      ]
      results = {}
      assocs_cache = {}

      begin
        for_each_model_instance do |model, instance|
          results[model] ||= {}
          assocs = assocs_cache[model] ||= model.reflect_on_all_associations

          assocs.each do |assoc|
            next if OK_TO_BE_NIL.include?([model, assoc.name])
            value = instance.send(assoc.name)
            has_nil = (assoc.collection? && (value.include?(nil) || value.empty?)) || (!assoc.collection? && value.nil?)
            if has_nil
              results[model][assoc.name] ||= []
              results[model][assoc.name] << instance
            end
          end
        end
      rescue Exception => e
        $stderr.puts "Encountered exception #{e}\n#{e.backtrace.join("\n")}"
      ensure
        $stderr.puts "\n"
        results.each do |model, assocs|
          assocs.each do |assoc, instances|
            $stderr.puts "#{model.name}\##{assoc}: #{instances.map{|i| i.id}.inspect}\n"
          end
        end
      end
    end
  end
end
