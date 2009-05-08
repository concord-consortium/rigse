# for magic rails strings:
require 'rubygems'
require 'active_support'

# Process files in the app/ directory:
# renaming model files, and repacing substrings matching model name.
# use with caution, and check results with git before committing.

def rename(old_name,new_name)
  #rename files:
  types = "{rb,haml,erb,html}"

  # specify the replacesments list, to ensure 
  # the correct ordering of 'each'...
  replacements = [
    {
      :old => old_name.tableize.pluralize,
      :new => new_name.tableize.pluralize
    },{
      :old => old_name.tableize,
      :new => new_name.tableize
    },{
      :old => old_name.classify,
      :new => new_name.classify
    },{
      :old => old_name.foreign_key,
      :new => new_name.foreign_key
    }
  ]
  replacements.each do |replacement|
    Dir.glob(File.join("../app/**","*.#{types}")) do |filename| 
      if filename =~ /#{replacement[:old]}/
        exec "mv #{filename} #{filename.gsub(replacement[:old],replacement[:new])}"
      end
      exec "sed -i -n 's/#{replacement[:old]}/#{replacement[:new]}/g' #{filename}"
    end
  end
end


def exec(command)
  puts command
  # puts %x[command]
end

rename ('Investigation','Activity')