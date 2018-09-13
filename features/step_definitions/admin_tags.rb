# Table: | cohorts | tag |
Given /^the following tags exist:$/ do |tags_table|
  tags_table.hashes.each do |hash|
    begin
      tag = FactoryGirl.create(:admin_tag, hash)
    rescue ActiveRecord::RecordInvalid
      # assume this user is already created...
    end
  end
end
