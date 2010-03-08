# for magic rails strings:
require 'rubygems'
require 'active_support'

# Process files in the app/ directory:
# renaming model files, and repacing substrings matching model name.
# use with caution, and check results with git before committing.

def rename(old_name,new_name)
  #rename files:
  types = "{rb,haml,erb,html,rjs,js}"

  # specify the replacesments list, to ensure 
  # the correct ordering of 'each'...
  replacements = [
    {
      :old => old_name.tableize,
      :new => new_name.tableize
    },{
      :old => old_name.classify.pluralize,
      :new => new_name.classify.pluralize
    },{
      :old => old_name.tableize.singularize,
      :new => new_name.tableize.singularize
    },{
      :old => old_name.classify,
      :new => new_name.classify
    },{
      :old => old_name.foreign_key,
      :new => new_name.foreign_key
    }
  ]
  replacements.each do |replacement|
    puts "replacing #{replacement[:old]} => #{replacement[:new]} "
    Dir.glob(File.join("../app/**","*.#{types}")) do |filename| 
      # look for files containting our replacement text:
      found_path =  exec "grep #{replacement[:old]} -l #{filename}"
      if (found_path.size > 0)
        # replace:
        exec "sed -i '' 's/#{replacement[:old]}/#{replacement[:new]}/g' #{filename}"
      end
      
      # rename matching patterns:
      if filename =~ /#{replacement[:old]}/
        exec "mv #{filename} #{filename.gsub(replacement[:old],replacement[:new])}"
      end
    end
    # we should change the routes file too:
    puts exec "sed -i '' 's/#{replacement[:old]}/#{replacement[:new]}/g' ../config/routes.rb"
  end
end


def exec(command)
  #return command
  return %x[#{command}]
end

# rename ('Investigation','Activity')