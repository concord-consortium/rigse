Gem::Specification.new do |s|
  s.name = "railroad"
  s.version = "0.7.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Javier Smaldone", "Thomas Ritz", "Tien Dung", "Factory Design Labs", "Mike Mondragon", "Tero Tilus", "David Dollar", "Bruno Michel"]
  s.date = "2009-03-14"
  s.default_executable = "railroad"
  s.description = "RailRoad is a class diagrams generator for Ruby on Rails applications."
  s.email = "javier@smaldone.com.ar"
  s.executables = ["railroad"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["COPYING", "ChangeLog", "History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/railroad", "init.rb", "lib/railroad.rb", "lib/railroad/aasm_diagram.rb", "lib/railroad/app_diagram.rb", "lib/railroad/controllers_diagram.rb", "lib/railroad/diagram_graph.rb", "lib/railroad/models_diagram.rb", "lib/railroad/options_struct.rb", "lib/railroad/tasks/diagrams.rb", "lib/railroad/tasks/diagrams.rake"]
  s.has_rdoc = true
  s.homepage = "http://railroad.rubyforge.org"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "railroad"
  s.rubygems_version = "1.2.0"
  s.summary = "A DOT diagram generator for Ruby on Rail applications"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 2 then
      s.add_development_dependency("hoe", [">= 1.7.0"])
    else
      s.add_dependency("hoe", [">= 1.7.0"])
    end
  else
    s.add_dependency("hoe", [">= 1.7.0"])
  end
end
