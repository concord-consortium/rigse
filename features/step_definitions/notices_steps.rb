Then /^the notices have loaded$/ do
  using_wait_time(10) do
    expect(page).to have_no_content("Loading notices")
  end
end
