module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      '/'
    
    when /my home\s?page/
      '/home'
    when /the pick signup page/
      '/pick_signup'
    when /to the link tool/
      '/linktool'
    when /the current project edit page/
      "/admin/projects/#{Admin::Project.default_project.id}/edit"
    when /the current project show page/  
      "/admin/projects/#{Admin::Project.default_project.id}/show"

    # accept paths too:
    when /\/[\S+\/]+/
      page_name
      
    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
