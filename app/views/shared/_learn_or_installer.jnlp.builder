locals = { :runnable => runnable, :learner => learner, :jnlp_session => local_assigns[:jnlp_session]}

if skip_installer || !(current_project.opportunistic_installer?)
  xml << render(:partial => 'shared/learn', :locals => locals)
else
  xml << render(:partial => 'shared/installer', :locals => locals)
end