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
    when /my preferences/
      "/users/#{User.find_by_login(@cuke_current_username).id}/preferences"
    when /the pick signup page/
      '/pick_signup'
    when /the student signup page/
      '/portal/students/signup'
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
    when /the reports for resource pages/
      "/reports/resource_pages"
    when /the class page for "(.*)"/
      "/portal/classes/#{Portal::Clazz.find_by_name($1).id}"
    when /the class edit page for "([^"]*)"/
        clazz = Portal::Clazz.find_by_name($1)
        edit_portal_clazz_path(clazz)
    when /the investigations printable index page/
      "/investigations/printable_index"
    when /the investigations page for "(.*)"/
      inv = Investigation.find_by_name $1
      investigation_path inv
    when /the investigations like "(.*)"/
      "/investigations?name=#{$1}"
    when /the resource pages printable index page/
      "/resource_pages/printable_index"
    when /the resource pages like "(.*)"/
      "/resource_pages?name=#{$1}"
    when /the resource page for "(.*)"/
      "/resource_pages/#{ResourcePage.find_by_name($1).id}"
    when /the clazz create page/
      new_portal_clazz_path
    when /the edit web model page for "(.*)"/
      web_model = WebModel.find_by_name $1
      edit_web_model_path web_model
    when /the web model page for "(.*)"/
      web_model = WebModel.find_by_name $1
      web_model_path web_model
    # accept paths too:
    when /the route (.+)/
      $1
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
