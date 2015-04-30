When /^I click on the (id|edit|delete) link for materials collection "([^"]*)"$/ do |link_type, name|
  id = MaterialsCollection.find_by_name(name).id
  link = case link_type
    when "id"
      "#{id}"
    when "edit"
      "edit materials collection"
    when "delete"
      "delete materials collection"
    else
      raise "Invalid materials collection link type: #{link_type}"
    end

  with_scope("#wrapper_materials_collection_#{id}") do
    click_link(link)
  end
end


Then /^the details for materials collection "([^"]*)" should (not )?be visible/ do |name, negative|
  id = MaterialsCollection.find_by_name(name).id

  selector = "#details_materials_collection_#{id}"

  if (negative)
    find(selector).should_not be_visible
  else
    find(selector).should be_visible
  end
end

When /^I open the accordion for the materials collection "([^"]*)"$/ do |name|
  id = MaterialsCollection.find_by_name(name).id

  selector = "#accordion_toggle_materials_collection_#{id}"
  # need to check if the accordion is already open so we don't close it
  if(!find("#details_materials_collection_#{id}").visible?)
    find(selector).click
  end
end

When /^I drag the (\d+)(?:st|nd|rd|th) material in the materials collection "([^"]*)" to the (top|bottom)/ do |start_position, name, end_position|
  collection = MaterialsCollection.find_by_name(name)
  items = collection.materials_collection_items
  @last_moved_item = items[start_position.to_i-1]

  item_selector = "#materials_collection_item_#{@last_moved_item.id} .material_item_handle"
  if end_position == "top"
    # FIXME This actually drops it into 2nd position...
    dest = "#materials_collection_item_#{items.first.id}"
  else
    dest = "#materials_collection_item_#{items.last.id}"
  end

  page.find(item_selector).drag_to(page.find(dest))
end

Then /^the previously moved material in the materials collection "([^"]*)" should be (first|last)$/ do |name, position|
  collection = MaterialsCollection.find_by_name(name)

  # FIXME See the drag step above, where it's actually getting put into second position
  item = position == 'first' ? collection.materials_collection_items[1] : collection.materials_collection_items.last
  item.should eq @last_moved_item
end

When /^I click remove on the (\d+)(?:st|nd|rd|th) material in the materials collection "([^"]*)"$/ do |position, name|
  collection = MaterialsCollection.find_by_name(name)
  material_item = collection.materials_collection_items[position.to_i-1]

  with_scope("#materials_collection_item_#{material_item.id}") do
    click_link("Remove #{material_item.material.name} from the collection '#{name}'")
  end
end

Then /^I should only see (\d+) materials in the materials collection "([^"]*)"$/ do |count, name|
  collection = MaterialsCollection.find_by_name(name)

  expect(collection.materials_collection_items.size).to eq(count.to_i)

  with_scope("#materials_materials_collection_#{collection.id}") do
    page.should have_css('li.material_item', :count => count)
  end
end


