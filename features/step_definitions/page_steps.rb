Given /^the following page exists:$/ do |page_table|
  page_table.hashes.each do |hash|
    user_name = hash.delete('user')
    user = User.find_by_login user_name

    hash['user'] = user
    Factory :page, hash
  end
end
