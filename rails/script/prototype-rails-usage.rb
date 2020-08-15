#!/usr/bin/env ruby

prototype_rails_methods = [
  "remote_form_for",
  "visual_effect",
  "link_to_remote",
  "link_to_function",
  "sortable_element",
  "drop_receiving_element",
  "button_to_remote",
  "draggable_element",
  "observe_form",
  "remote_function",
]

helpers_that_use_prototype_rails = [
  "wrap_edit_link_around_content",
  "toggle_all",
  "toggle_more",
  "remote_link_button",
  "function_link_button",
  "remove_link",
  "student_add_dropdown",
  "teacher_add_dropdown",
  "edit_button_for", # uses remote_link_button
  "delete_button_for", # uses remote_link_button
  "show_menu_for", # uses edit_button_for and delete_button_for
]

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

def grep_files(directory, strings, function=false, prefix='', suffix='')
  original_dir = Dir.pwd
  Dir.chdir directory
  results = []
  last_def = ""
  Dir['**/*'].sort.each do |file_name|
    next unless File.file?(file_name)
    File.open file_name do |file|
      file.each_with_index do |line,line_number|
        if line.match("def ")
          last_def = line.strip
        end
        strings.each do |method|
          # don't match the method if it is preceded by a _
          if line.match("#{prefix}(?<![_\"])#{method}(?![_\"])#{suffix}")
            if function
              results << ["#{file_name}:#{line_number+1}", method, last_def, md_code(line)]
            else
              results << ["#{file_name}:#{line_number+1}", method, md_code(line)]
            end
          end
        end
      end
    end
  end
  Dir.chdir original_dir
  results
end

puts "# Prototype Rails Usage"
puts ""
puts "This was generated by"
puts "```"
puts "cd rails/script"
puts "ruby prototype-rails-usage.rb > ../../docs/prototype-rails-usage.md"
puts "```"

# This adds an additional table just linksing views that directly use
# the prototype rails functions
# results = grep_files("../app/views", prototype_rails_methods)
# print_md_table("Views directly using prototype-rails",
#   ["file", "method", "line" ],
#   results
# )

results = grep_files("../app/helpers", prototype_rails_methods, true)
print_md_table("Helpers directly using prototype-rails",
  ["file", "helper", "function", "line" ],
  results
)

# use a negative look behind to skip the actual function definitions themseleves
results = grep_files("../app/helpers", helpers_that_use_prototype_rails, true, "(?<!def )")
print_md_table("Helpers using helpers which use prototype-rails",
  ["file", "helper", "function", "line" ],
  results
)

results = grep_files("../app/views", prototype_rails_methods + helpers_that_use_prototype_rails)
print_md_table("Views that use prototype-rails or a helper that uses it",
  ["file", "helper", "line" ],
  results
)

summary = results.group_by{|result| result[0].split(":")[0]}.map{|key,value| [key, value.length.to_s]}
print_md_table("Summary of views",
  ["file", "number of refs to helpers"],
  summary
)
