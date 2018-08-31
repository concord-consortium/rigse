module FeatureHelper
  def login_as(username)
    visit "/login/#{username}"
    expect(page).to have_content(username)
  end
end