require 'rake'
require 'hpricot'

namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/*'
    task :import_from_file => :environment do
      parser = Parser.new

      # delete old stuff
      parser.remove_old_data
      
      parser.make_domains(File.join [RAILS_ROOT] + %w{config rigse_data domains.yml})
      parser.make_themes(File.join [RAILS_ROOT] + %w{config rigse_data themes.yml})
      parser.parse(File.join [RAILS_ROOT] + %w{config rigse_data rigse_k12_sci_doc_convert.xhtml})
      parser.parse_ri_goals_xls(File.join [RAILS_ROOT] + %w{config rigse_data ri_goals.xls})
    end
  end
end