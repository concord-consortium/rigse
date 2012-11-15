module HtmlSelectorsHelpers
  # Maps a name to a selector. Used primarily by the
  #
  #   When /^(.+) within (.+)$/ do |step, scope|
  #
  # step definitions in web_steps.rb
  #
  def selector_for(locator)
    case locator

    when "the page"
      "html > body"
    when "left panel for class navigation"
      "div#clazzes_nav"
    when "the popup"
      "div.ui-window div.content"
    when "the tab block for Instructional Materials"
      "div#oTabcontainer"
    when "activity button list of Instructional Material page"
      "table.materials"
    when "the first recent activity on the recent activity page"
      [:xpath, "//div[@class=\"recent_activity_container\"]/div[1]"]
    when "the activity table"
      [:xpath, "//div[@class = 'progress_div webkit_scrollbars']/table"]
    when "suggestion box"
      "div#suggestions"
    when "result box"
      "div.results_container"
    when "the student list on the student roster page" 
      "div#students_listing"
    when "the assign materials popup on the search page"
      "div.ui-window.lightbox.draggable.resizable.lightbox_focused"
    when "the message popup on the admin projects page"
      "div.ui-window.lightbox.draggable.resizable.lightbox_focused"
    when "the no report popup on the instructional materials page"
      "div.ui-window.lightbox.draggable.resizable.lightbox_focused"
    when "the top navigation bar"
      "div#nav_top"
    when "header login box"
      "form#header-project-signin"
    when "content box in change password page"
      "div#content"
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #  when /^the (notice|error|info) flash$/
    #    ".flash.#{$1}"

    # You can also return an array to use a different selector
    # type, like:
    #
    #  when /the header/
    #    [:xpath, "//header"]

    # This allows you to provide a quoted selector as the scope
    # for "within" steps as was previously the default for the
    # web steps:
    when /^"(.+)"$/
      $1
    when /^(#.+)$/
      $1

    else
      raise "Can't find mapping from \"#{locator}\" to a selector.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(HtmlSelectorsHelpers)
