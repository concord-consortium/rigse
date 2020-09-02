require 'yaml'

reference_tree_yaml = File.read('../../docs/prototype-rails-references.yaml')
@reference_tree = YAML.load(reference_tree_yaml)

solutions_file_name = '../../docs/prototype-rails-solutions.yaml'
solutions_yaml = File.read(solutions_file_name)
@solutions = YAML.load(solutions_yaml)

exploded_file_name = '../../docs/prototype-rails-exploded-references.yaml'
exploded = []

@current_path = []

def explode(block_name, top_level=false)
  block = @reference_tree[block_name]
  if(block["callers"])
    if(@current_path.include?(block_name))
      "#{block_name} (circular)"
    elsif(!top_level and @solutions[block_name] and @solutions[block_name]["solution"])
      "#{block_name} (solved)"
    else
      @current_path.push(block_name)
      caller_names = block["callers"].map{|caller| caller["name"]}
      return_value = {
        # recurse
        # FIXME need to detect infinite loops
        block_name => caller_names.map{|caller_name| explode(caller_name)}
      }
      @current_path.pop()
      return_value
    end
  else
    if(@solutions[block_name] and @solutions[block_name]["solution"])
      "#{block_name} (solved)"
    else
      block_name
    end
  end
end

# Do explosion
@reference_tree.each do |name, block|
  next if(name.start_with?("BASE/"))
  # add the basic callers
  exploded << explode(name, true)
  if(@current_path.length > 0)
    abort("current_path wasn't completely popped on: #{name}")
  end
end

# sorted_exploded = exploded.sort
puts "Writing: #{exploded_file_name}"

File.open(exploded_file_name, 'w') do |f|
  f.write "# This was generated using: cd rails/script; ruby prototype-rails-explode-tree.rb\n"
  f.write exploded.to_yaml
end
