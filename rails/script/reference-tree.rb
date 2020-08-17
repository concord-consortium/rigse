
def print_md_table(title, headers, rows)
  puts "## #{title}"
  puts ''

  # add row index colum
  # we aren't using unshift so we don't modify the input arguments
  headers = [""] + headers
  rows = rows.map.with_index do |row, index|
    [(index+1).to_s] + row
  end

  padded_headers = headers.map.with_index do |header, index|
    max_cell_length = rows.map{|row| row[index].length}.max
    header.ljust(max_cell_length)
  end
  puts "| #{padded_headers.join(" | ")} |"
  puts "| #{padded_headers.map{|h| "-"*h.length}.join(" | ")} |"
  rows.each do |row|
    padded_cells = row.map.with_index{|item, index| item.ljust(padded_headers[index].length)}
    puts "| #{padded_cells.join(" | ")} |"
  end
  puts ''
end

def md_code(code)
  # escape the | since it is picked up by the md table parser
  escaped = code.gsub("|","\\|")
  "`#{escaped.strip}`"
end

# blocks are key'd by their filename if they are view
# if they are helper method, then they are keyd by filename#method
# if they are a controller then filename#method
# each block has a list of callers, these are other blocks that
# call or use this block

# We start with pre-existing helpers that are labeled with BASE

known_blocks = {}
blocks_to_process = {
  "BASE/remote_form_for" => {},
  "BASE/visual_effect" => {},
  "BASE/link_to_remote" => {},
  "BASE/link_to_function" => {},
  "BASE/sortable_element" => {},
  "BASE/drop_receiving_element" => {},
  "BASE/button_to_remote" => {},
  "BASE/draggable_element" => {},
  "BASE/observe_form" => {},
  "BASE/remote_function" => {},
}

def find_call_to_block(block_name, file_name, line)
  # line.match("(?<![_\"])#{method}(?![_\"])")

  if(block_name.start_with?("BASE/"))
    method = block_name.slice(/BASE\/(.*)/, 1)
    # don't match the method if it is preceded by a _ or "
    line.match(/(?<![_"])#{method}(?![_"])/)
  elsif(block_name.start_with?("views/"))
    block_file_name = block_name.split('/')[-1]
    # FIXME: skip the run_html for now since we don't handle formats yet
    if(block_file_name.start_with?("_") and !block_file_name.end_with?("run_html.haml"))
      # this is a partial
      # we should allow
      # ", ', or : before it
      # and when looking for the block in the same directory then we should
      # add the prefix of the folder, but when looking outside of the directory
      # then we need to include folder prefix
      block_directory = block_name.slice(/views\/(.*)\/[^\/]*/,1)
      if(file_name.start_with?("views/"))
        # relative refences are allow when a view is referencing a partial in the same folder
        relative_path_allowed = block_directory == file_name.slice(/views\/(.*)\/[^\/]*/,1)
      elsif(file_name.start_with?("controllers/"))
        # controllers can reference partials without the full name if they are in the same folder
        # example:
        #   partial: views/search/_material_unassigned_collections.html.haml
        #   reference_file: controllers/search_controller.rb
        # we need to take the block_directory strip off the last segment and turn it into
        #
        relative_path_allowed = file_name == "controllers/#{block_directory}_controller.rb"
      else
        # FIXME: we disable relative_path_allowed for everything else inorder to reduce false postives.
        # there is a '_user' partial so that ends up matching lots of stuff that isn't a partial
        # Once we add the match for `partial =>` or `partial:` then we can probably renable relative
        # paths and see if we pick up any more legitimate matches
        relative_path_allowed = false
      end

      block_partial_name = block_file_name.slice(/_([^\.]*)/,1)
      # FIXME: this is not a great match way to match 'partial'
      (relative_path_allowed and line.match(/partial.*["':]#{block_partial_name}(?![_a-zA-Z])/)) or
      (line.match(/partial.*["':]#{block_directory}\/#{block_partial_name}(?![_a-zA-Z])/))
    else
      # this is a top level view
      # when we start searching controllers we can probably figure out
      # which controllers would be referencing this view
      false
    end
  elsif(block_name.start_with?("helpers/") or block_name.start_with?("lib/"))
    method = block_name.split('#')[1]
    line.match(/(?<!def )(?<![_"])#{Regexp.escape(method)}(?![_"])/)
  elsif(block_name.start_with?("controllers/"))
    # we don't handle calls to controllers yet
    # a call to a controller would typically be in a view and would be a reference
    # to its route helper. So to make this work we need the output of rake routes
    # which we can process to find the name and the controller action
    false
  else
    # we should add additional matchers here
    false
  end
end

def current_block_name(file_name, last_def)
  # for now we just return the file_name
  # for helpers, controllers, and libs we need to also include
  # the last_def, but it needs to be stripped down
  if(file_name.start_with?("views/"))
    file_name
  elsif((file_name.start_with?("helpers/") or file_name.start_with?("lib/") or file_name.start_with?("controllers/")) and
    file_name.end_with?(".rb") and !last_def.nil?)
    # need to get the method name from the last def
    method = last_def.slice(/def ([^ (]*)/, 1)
    "#{file_name}##{method}"
  else
    puts "Unable to process: #{file_name}, function: #{last_def}"
  end
end

def grep_files(directory, blocks, new_blocks)
  original_dir = Dir.pwd
  if(directory == "lib")
    Dir.chdir "../lib"
    glob = '**/*.rb'
  else
    Dir.chdir "../app/#{directory}"
    glob = '**/*'
  end
  results = []
  last_def = ""
  Dir[glob].sort.each do |file_name|
    next unless File.file?(file_name)
    File.open file_name do |file|
      file_name = "#{directory}/#{file_name}"
      file.each_with_index do |line,line_number|
        if line.match("def ")
          last_def = line.strip
        end
        blocks.each do |block_name, block|
          if(find_call_to_block(block_name, file_name, line))
            caller_block_name = current_block_name(file_name, last_def)
            if(caller_block_name)
              # we are going to be running this function multiple times
              # over different directories. The directories shouldn't overlap
              # so there should never be an existing new_block
              new_blocks[caller_block_name] = {}
              if(block["callers"].nil?)
                block["callers"] = []
              end
              block["callers"] << {
                "name"=> caller_block_name,
                "line"=> line.strip
              }
            end
          end
        end
      end
    end
  end
  Dir.chdir original_dir
  results
end

require 'yaml'

# now we iterate until new_blocks is empty
# on each iteration we go through all of the files and for
# on each line we search for references to each new_block
# the searching is customized based on the current file name
# and block being searched for
while(blocks_to_process.length > 0)
  puts "Looking for callers of:"
  puts blocks_to_process.keys.to_yaml
  # initially we are just going to search the views directory but this will
  # expand to search the full app directly and the lib folder too
  new_blocks = {}
  grep_files("views", blocks_to_process, new_blocks)
  grep_files("helpers", blocks_to_process, new_blocks)
  grep_files("lib", blocks_to_process, new_blocks)
  grep_files("controllers", blocks_to_process, new_blocks)

  # this will overwrite any existing known_blocks that match the processed blocks
  # that case shouldn't happen though
  known_blocks.merge!(blocks_to_process)
  # inorder to handle circular references we should not re-process any new_blocks
  # that are known already
  blocks_to_process = {}
  new_blocks.each do |key,value|
    blocks_to_process[key] = value unless known_blocks.has_key?(key)
  end
end

# Add reverse tree info too
known_blocks.each do |name, block|
  next if block["callers"].nil?

  block["callers"].each do |caller|
    caller_name = caller["name"]
    calls = known_blocks[caller_name]["calls"]
    if calls.nil?
      calls = []
      known_blocks[caller_name]["calls"] = calls
    end
    calls << name
  end
end

sorted_known_blocks = known_blocks.sort.to_h
puts "Found Block Names:"
puts sorted_known_blocks.keys.to_yaml

output_file = "../../docs/prototype-rails-references.yaml"
puts "Writing: #{output_file}"

File.open(output_file, 'w') do |f|
  f.write "# This was generated using: cd rails/script; ruby reference-tree.rb\n"
  f.write sorted_known_blocks.to_yaml
end
