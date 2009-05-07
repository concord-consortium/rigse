


# note to self!! Exclude DB directory!
def rename(old_name,new_name,exludes)
  #rename files:
  types = "{rb,haml,erb,html}"
  Dir.glob(File.join("../app/**","*.#{types}")) do |name| 
    if name =~ /#{old_name}/
      exec "mv #{name} #{name.gsub(old_name,new_name)}"
    end
    exec "sed #{name} 's/#{old_name}/#{new_name}/g'"
  end
end


def exec(command)
  # puts command
  puts %x[command]
end

rename ('investigation','activity',[])