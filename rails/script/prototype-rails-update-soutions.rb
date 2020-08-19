require 'yaml'

reference_tree_yaml = File.read('../../docs/prototype-rails-references.yaml')
reference_tree = YAML.load(reference_tree_yaml)

solutions_file_name = '../../docs/prototype-rails-solutions.yaml'
solutions_yaml = File.read(solutions_file_name)
solutions = YAML.load(solutions_yaml)

reference_tree.each do |name, block|
  next if(solutions[name])
  next if(name.start_with?("BASE/"))
  solutions[name] = {
    "solution"=> nil,
    "rational"=> nil,
    "story"=> nil
  }
end

sorted_solutions = solutions.sort.to_h
puts "Writing: #{solutions_file_name}"
File.open(solutions_file_name, 'w') do |f|
  f.write "# This was generated using: cd rails/script; ruby prototype-railsupdate-solutions.rb\n"
  f.write sorted_solutions.to_yaml
end

unsolved_files = sorted_solutions.filter{|name, solution| solution["solution"].nil?}
puts unsolved_files.map{|name, solutions| name}.to_yaml
puts "Unsolved files: #{unsolved_files.length}"
puts "Total files #{sorted_solutions.length}"
