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
    expect(find(selector, visible: false)).not_to be_visible
  else
    expect(find(selector)).to be_visible
  end
end

When /^I open the accordion for the materials collection "([^"]*)"$/ do |name|
  id = MaterialsCollection.find_by_name(name).id

  selector = "#accordion_toggle_materials_collection_#{id}"
  # need to check if the accordion is already open so we don't close it
  if(!find("#details_materials_collection_#{id}", visible: false).visible?)
    find(selector).click
  end
end

def set_sortable_sequence(sortable_container_id, sequence)
  page.execute_script("Sortable.setSequence(jQuery('##{sortable_container_id}')[0], #{sequence})")
end

When /^I drag the (\d+)(?:st|nd|rd|th) material in the materials collection "([^"]*)" to the (top|bottom)/ do |start_position, name, top_or_bottom|
  collection = MaterialsCollection.find_by_name(name)
  ids = collection.materials_collection_items.pluck(:id)
  zero_based_index_position = start_position.to_i - 1
  @id_of_item_moved = ids[zero_based_index_position]
  sortable_container_id = dom_id_for(collection, :materials)

  if top_or_bottom == 'top'
    set_sortable_sequence(sortable_container_id, ids.unshift(ids.delete_at(zero_based_index_position)))
  else
    set_sortable_sequence(sortable_container_id, ids.push(ids.delete_at(zero_based_index_position)))
  end

  # Trigger the onUpdate callback after changing sequence programmatically
  page.execute_script("Sortable.options(jQuery('##{sortable_container_id}')[0]).onUpdate()")
end

Then /^the previously moved material in the materials collection "([^"]*)" should be (first|last)$/ do |name, position|
  collection = MaterialsCollection.find_by_name(name)

  item = position == 'first' ? collection.materials_collection_items.first : collection.materials_collection_items.last
  expect(item.id).to eq @id_of_item_moved
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
    expect(page).to have_css('li.material_item', :count => count)
  end
end
