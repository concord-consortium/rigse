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
    when /the create investigation page/
      "/investigations/new"
    when /the create resource page page/
      "/resource_pages/new"
    when /the resource pages page/
      "/resource_pages/"
    when /the resource pages with drafts page/
      "/resource_pages/?include_drafts=true"
    # accept paths too:
    when /\/[\S+\/]+/
      page_name
      

    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
