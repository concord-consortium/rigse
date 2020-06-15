module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    when /the root path/
      "/"
    when /the home\s?page/
      '/home'
    when /my classes page/
      '/my_classes'
    when /getting started page/
      '/getting_started'
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
    when /the current settings edit page/
      "/admin/settings/#{Admin::Settings.default_settings.id}/edit"
    when /the current settings show page/
      "/admin/settings/#{Admin::Settings.default_settings.id}/show"
    when /the researcher reports page and click usage report/
      WebMock.stub_request(:post, /report_learners\/_search$/).
        to_return(:status => 200, :body => { "hits" => { "hits" => [] } }.to_json,
          :headers => {'Content-Type'=>'application/json'})
      "/report/learner?commit=Usage+Report"
    when /the researcher reports page and click details report/
      WebMock.stub_request(:post, /report_learners\/_search$/).
        to_return(:status => 200, :body => { "hits" => { "hits" => [] } }.to_json,
          :headers => {'Content-Type'=>'application/json'})
      "/report/learner?commit=Details+Report"
    when /the class page for "(.*)"/
      "/portal/classes/#{Portal::Clazz.find_by_name($1).id}"
    when /the class edit page for "([^"]*)"/
        clazz = Portal::Clazz.find_by_name($1)
        edit_portal_clazz_path(clazz)
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
    when /browse materials page for "(.+)"/
      eresource = ExternalActivity.find_by_name $1
      "/browse/eresources/#{eresource.id}"
    when /material preview page for "(.+)"/
      eresource = ExternalActivity.find_by_name $1
      slug = eresource.name.parameterize
      "/resources/#{eresource.id}/#{slug}"
    when /Instructional Materials page for "(.+)"/
      portal_clazz = Portal::Clazz.find_by_name $1
      "/portal/classes/#{portal_clazz.id}/materials"
    when /report of offering "(.+)"/
      eresource = ExternalActivity.find_by_name($1)
      offering = Portal::Offering.find_by_runnable_id eresource.id
      "/portal/offerings/#{offering.id}/report"
    when /the Help Page/
      "/help"
    when /the projects index page/
      "/admin/projects"
    when /the materials collection index page/
      "/materials_collections"
    when /the show page for materials collection "([^"]+)"/
      collection = MaterialsCollection.find_by_name($1).id
      "/materials_collections/#{collection}"
    when /the interactives index page/
      "/interactives"
    when /the show page for interactive "([^"]+)"/
      interactive = Interactive.find_by_name($1).id
      "/interactives/#{interactive}"
    when /the edit page of interactive "([^"]+)"/
      interactive = Interactive.find_by_name($1).id
      "/interactives/#{interactive}/edit"
    when /the signin page/
      "/auth/login"
    when /the new material page/
      "/eresources/new"
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
