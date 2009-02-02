require 'rake'
require 'hpricot'

namespace :rigse do
  namespace :setup do
    #
    #
    #
    desc 'import grade span expectations from file config/rigse_data/rigse_k12_sci_doc_convert.xhtml'
    task :import_from_file => :environment do
      parser = Parser.new
      parser.parse(File.join [RAILS_ROOT] + %w{config rigse_data rigse_k12_sci_doc_convert.xhtml})
    end
  end
end