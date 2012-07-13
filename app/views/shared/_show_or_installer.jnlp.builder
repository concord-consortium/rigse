locals = { :runnable => runnable, :teacher_mode => teacher_mode }

if skip_installer || !(current_project.opportunistic_installer?)
  xml << render(:partial => 'shared/show', :locals => locals)
else
  xml << render(:partial => 'shared/installer', :locals => locals)
end
