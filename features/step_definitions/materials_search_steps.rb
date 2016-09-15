Then /I search for my own materials/ do
  search_mine_string = I18n.translate("Search.only_mine")
  Then "I should see #{search_mine_string}"
end