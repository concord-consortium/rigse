require 'rake'
require 'hpricot'
namespace :importer do
  load 'config/environment.rb'
  #
  #
  #
  desc 'sample thing for noa'
  task :import_from_file do
    parser = Parser.new
    parser.parse("config/rigse_data.xhtml")
  end
  
  namespace :install do
    # nothing
  end
  
  #
  #
  #
  desc 'create the learning domains for risge'
  task :make_domains do
    domains = [
      ["Life Science", "LS"],
      ["Earth and Space Science","ESS"],
      ["Physical Science", "PS"]]

    domains.collect { |d|
      d = Domain.new(:key => d[1], :name => d[0])
      d.save
    }
  end

  #
  #
  #
  desc 'make the unifying themes for risge'
  task :make_themes do
    unifying_themes = [
      ["INQ", "Scientific Inquiry"],
      ["NOS", "Nature of Science"],
      ["SAE", "Systems & Energy"],
      ["MOS", "Models & Scale"],
      ["POC", "Patterns of Change"],
      ["FOF", "Form & Function"]
    ]

    unifying_themes.collect { |t|
      theme = UnifyingTheme.new(:key => t[0], :name => t[1])
      theme.save
    }
  end

end