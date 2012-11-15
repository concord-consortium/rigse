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
    when /user list/
      '/users'
    when /the districts page/
      portal_districts_path
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
    when /the researcher reports page/
      "/report/learner"
    when /the class page for "(.*)"/
      "/portal/classes/#{Portal::Clazz.find_by_name($1).id}"
    when /the class edit page for "([^"]*)"/
        clazz = Portal::Clazz.find_by_name($1)
        edit_portal_clazz_path(clazz)
    when /the investigations printable index page/
      "/investigations/printable_index"
    when /the investgations page/
      "/investigations/"
    when /the investigations page for "(.*)"/
      inv = Investigation.find_by_name $1
      investigation_path inv
    when /the first page of the "(.*)" investigation/ 
      investigation = Investigation.find_by_name($1)
      page = investigation.pages.first
      page_path(page)
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
    when /the user preferences page for the user "(.*)"/
      user = User.find_by_login $1
      preferences_user_path user
    when /the switch page/
      switch_user_path User.find_by_login(@cuke_current_username)
    when /the requirements page/
      "/requirements/"
    when /the about page/
      "/about"
    when /the admin create notice page/
      "/admin/site_notices/new"
    when /the site notices index page/  
      "/admin/site_notices"
    when /the password reset page/
      "/change_password/0"
    when /the edit security questions page for the user "(.*)"/
      user = User.find_by_login $1
      edit_user_security_questions_path user
    # accept paths too:
    when /the route (.+)/
      $1
    when /\/[\S+\/]+/
      page_name
    when /the class edit page for "(.+)"/
      portal_clazz = Portal::Clazz.find_by_name $1
      "/portal/classes/#{portal_clazz.id}/edit"
    when /"Student Roster" page for "(.+)"/
      portal_clazz = Portal::Clazz.find_by_name $1
      "/portal/classes/#{portal_clazz.id}/roster"
    when /the full status page for "(.+)"/
      portal_clazz = Portal::Clazz.find_by_name $1
      "/portal/classes/#{portal_clazz.id}/fullstatus"
    when /Manage Class Page/
      "/portal/classes/manage"
    when /Recent Activity Page/
      "/recent_activity"
    when /the search instructional materials page/
      "/search"
    when /Instructional Materials page for "(.+)"/
      portal_clazz = Portal::Clazz.find_by_name $1
      "/portal/classes/#{portal_clazz.id}/materials"
    when /report of offering "(.+)"/
      investigation = Investigation.find_by_name($1)
      offering = Portal::Offering.find_by_runnable_id investigation.id
      "/portal/offerings/#{offering.id}/report"
    when /the Project Help Page/
      "/help"
    when /the preview investigation page for the investigation "(.*)"/
      investigation_id = Investigation.find_by_name($1).id
      "/browse/investigations/#{investigation_id}"
    when /the preview activity page for the activity "(.*)"/
      activity_id = Activity.find_by_name($1).id
      "/browse/activities/#{activity_id}"
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))
    
    else
      begin
        page_name =~ /^the (.*) page$/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue NoMethodError, ArgumentError
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
