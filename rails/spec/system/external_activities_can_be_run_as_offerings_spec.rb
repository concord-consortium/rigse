require 'spec_helper'

RSpec.describe 'External Activities can be run as offerings', type: :system do

  scenario 'External Activity offerings are runnable', js: true do
    assignable_type = "external activity"
    portal_class = Portal::Clazz.find_by_name('Class_with_no_assignment')
    typeName = assignable_type.gsub(/\s/, "_")
    assignable = typeName.classify.constantize.find_by_name("My Activity")
    FactoryBot.create(:portal_offering, {
      :runnable => assignable,
      :clazz => portal_class,
    })

    login_as("student")
    visit root_path
    expect(page).to have_content('Class_with_no_assignment')
    first(:link, 'Class_with_no_assignment').click
    expect(page).to have_content('MY ACTIVITY')
    expect(page).to have_content('Run')
    expect(page).to have_link('Run', href: /portal\/offerings\/\d+\.run_resource_html/)
  end

end
