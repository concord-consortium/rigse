
Given /^the following investigation exists:$/ do |investigation_table|
  investigation_table.hashes.each do |hash|
    @user = User.find_by_login(hash.delete('user'))
    hash[:user_id] = @user.id
    @investigation = Investigation.create(hash)
    @activity =Activity.create(hash)
    @section = Section.create(hash)
    @page = Page.create
    @section.pages << @page
    @activity.sections << @section
    @investigation.activities << @activity
    @investigation.save
  end
end

When /add a multiple choice question$/ do
  # pending # express the regexp above with the code you wish you had
end

When /show the first page of the "(.*)" investigation$/ do |investigation_name|
  investigation = Investigation.find_by_name(investigation_name)
  page = investigation.pages.first
  visit page_path(page)
end

