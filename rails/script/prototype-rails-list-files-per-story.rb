require 'yaml'

solutions_file_name = '../../docs/prototype-rails-solutions.yaml'
solutions_yaml = File.read(solutions_file_name)
solutions = YAML.load(solutions_yaml)

stories = {}
solutions.each do |name, block|
  story_urls = block["story"]
  if(!(story_urls.is_a? Array))
    story_urls = [story_urls]
  end
  story_urls.each do |story_url|
    file_list = stories[story_url]
    if(file_list.nil?)
      file_list = []
      stories[story_url] = file_list
    end
    file_list << name
  end
end

puts "Stories"
puts stories.to_yaml
