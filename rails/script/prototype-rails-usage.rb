#!/usr/bin/env ruby

#
def md_table(f, title, headers, rows)
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
  f.puts "| #{padded_headers.join(" | ")} |"
  f.puts "| #{padded_headers.map{|h| "-"*h.length}.join(" | ")} |"
  rows.each do |row|
    padded_cells = row.map.with_index{|item, index| item.ljust(padded_headers[index].length)}
    f.puts "| #{padded_cells.join(" | ")} |"
  end
  f.puts ''
end

def md_code(code)
  # escape the | since it is picked up by the md table parser
  escaped = code.gsub("|","\\|")
  "`#{escaped.strip}`"
end

require 'yaml'

reference_tree_yaml = File.read('../../docs/prototype-rails-references.yaml')
reference_tree = YAML.load(reference_tree_yaml)

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
    solution_list = stories[story_url]
    if(solution_list.nil?)
      solution_list = []
      stories[story_url] = solution_list
    end
    solution_list << {
      name: name,
      solution: block
    }
  end
end

# A top level summary section:
#   Number of remaning blocks referencing prototype-rails direct or indirect
#   Total number of blocks that we have solutiosn for
# A section for each story
#   A link to the PT story
#   A table listing the files and some kind of information about how they refernced
#   The table should indicate for each file, if it has been addressed or not
#   This can be told by if the solution is not manual, and there is no longer an
#   entry in the references

def block_fixed?(name, block, reference_tree)
  if(block["manual"])
    block["fixed"]
  else
    !reference_tree[name]
  end
end

unfixed_blocks = solutions.filter do |name, block|
  !block_fixed?(name, block, reference_tree)
end

usage_file_name = '../../docs/prototype-rails-usage.md'
puts "Writing: #{usage_file_name}"
File.open(usage_file_name, 'w') do |f|
  f.write <<~END_HEADER
    ## Summary

    Total number of blocks:  #{solutions.length}

    Blocks not fixed      : #{unfixed_blocks.length}

  END_HEADER

  stories.each do |story_url, blocks|
    story_id = story_url[/[^\/]*$/]
    f.write <<~END_STORY
      ## Story #{story_id}

      #{story_url}
    END_STORY
    # need to collect the blocks so we can make a table
    # fixed, name, num callers
    story_table = blocks.map do |block_def|
      block_name = block_def[:name]
      block = block_def[:solution]
      references = reference_tree[block_name]

      calls = []
      if(references && references["calls"])
        calls = references["calls"].map do |call|
          if(call.start_with?("BASE/"))
            call.slice(/BASE\/(.*)/, 1)
          else
            call[/[^\/]*$/]
          end
        end
      end

      [ block_fixed?(block_name, block, reference_tree) ? 'Y':'',
        block_name,
        calls.join(', '),
        references && references["callers"] ?  references["callers"].length.to_s : '',
      ]
    end

    md_table(f, "Blocks", ["Fixed", "Block", "Calls", "Num Callers"], story_table)
  end

  f.puts
  f.puts "-------"
  f.write "This was generated using: cd rails/script; ruby prototype-rails-usage.rb"
end


# This adds an additional table just linksing views that directly use
# the prototype rails functions
# results = grep_files("../app/views", prototype_rails_methods)
# print_md_table("Views directly using prototype-rails",
#   ["file", "method", "line" ],
#   results
# )

# results = grep_files("../app/helpers", prototype_rails_methods, true)
# print_md_table("Helpers directly using prototype-rails",
#   ["file", "helper", "function", "line" ],
#   results
# )
#
# # use a negative look behind to skip the actual function definitions themseleves
# results = grep_files("../app/helpers", helpers_that_use_prototype_rails, true, "(?<!def )")
# print_md_table("Helpers using helpers which use prototype-rails",
#   ["file", "helper", "function", "line" ],
#   results
# )
#
# results = grep_files("../app/views", prototype_rails_methods + helpers_that_use_prototype_rails)
# print_md_table("Views that use prototype-rails or a helper that uses it",
#   ["file", "helper", "line" ],
#   results
# )
#
# summary = results
#   .group_by{|result| result[0].split(":")[0]}
#   .map{|group_name,values| [group_name, values.map{|value| value[1]}.join(', ')]}
#
# print_md_table("Summary of views using prototype-rails",
#   ["file", "helpers"],
#   summary
# )
