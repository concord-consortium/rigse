
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

namespace :app do
  namespace :validate do
    desc "Process all of the model objects and find associations that have nil values"
    task :list_nil_associations => :environment do
      (puts "You must run this rake task in production mode!" and return) unless Rails.env.production?

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
      SKIP = [Itsi::Itsi, Ccportal::Ccportal, Embeddable::Embeddable, ActiveRecord::SessionStore::Session]
      results = {}
      load_all_models
      begin
        ar_models = ActiveRecord::Base.descendants.delete_if {|m| SKIP.include?(m) }.sort_by{|m| m.name }
        puts "Processing the following models:\n#{ar_models.map{|m| m.name}.join("\n")}"
        ar_models.each do |model|
          begin
            print "Processing #{model.count} #{model.name.pluralize}..."
            results[model] ||= {}
            assocs = model.reflect_on_all_associations
            count = 0
            model.find_each(:batch_size => 5) do |instance|
              print("\n%6d: " % count) if count % 2000 == 0
              assocs.each do |assoc|
                next if OK_TO_BE_NIL.include?([model, assoc.name])
                value = instance.send(assoc.name)
                has_nil = (assoc.collection? && value.include?(nil)) || (!assoc.collection? && value.nil?)
                if has_nil
                  results[model][assoc.name] ||= []
                  results[model][assoc.name] << instance
                end
              end
              count += 1
              print "." if count % 50 == 0
            end
            puts " done."
            # print model results
            results[model].each do |assoc, instances|
              $stderr.puts "#{model.name}\##{assoc}: #{instances.size}"
            end
            puts "\n"
          rescue Exception => ex
           $stderr.puts "Failed to process model: #{model.name}\n#{ex}"
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
