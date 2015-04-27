def store_activity_definition(name, content, modified = false)
  @activity_definitions ||= {}
  @activity_definitions[name] ||= {}
  version = modified ? :modified : :original
  @activity_definitions[name][version] = content
end

def get_activity_definition(name, modified = false)
  @activity_definitions ||= {}
  @activity_definitions[name] ||= {}
  version = modified ? :modified : :original
  @activity_definitions[name][version]
end

def store_sequence_definition(name, content, modified = false)
  @sequence_definitions ||= {}
  @sequence_definitions[name] ||= {}
  version = modified ? :modified : :original
  @sequence_definitions[name][version] = content
end

def get_sequence_definition(name, modified = false)
  @sequence_definitions ||= {}
  @sequence_definitions[name] ||= {}
  version = modified ? :modified : :original
  @sequence_definitions[name][version]
end

Given /^a(?:n)?( modified version of the)? external activity named "([^"]*)" with the definition$/ do |modified, name, string|
  store_activity_definition(name, string, modified.nil?)
end

Given /^a(?:n)?( modified version of the)? sequence named "([^"]*)" with the definition$/ do |modified, name, string|
  store_sequence_definition(name, string, modified.nil?)
end

Then /^the portal should create a(?:n)? (.*?) with the following attributes:$/ do |type, table|
  klass = case type
  when "investigation"
    Investigation
  when "external activity"
    ExternalActivity
  when "activity"
    Activity
  when "section"
    Section
  when "page"
    Page
  when "open response"
    Embeddable::OpenResponse
  when "multiple choice"
    Embeddable::MultipleChoice
  else
    raise "undefined object type: #{type}"
  end
  attrs = table.rows_hash
  if (attrs["name"])
    objs = klass.find_all_by_name(attrs["name"])
  elsif (attrs["prompt"])
    objs = klass.find_all_by_prompt(attrs["prompt"])
  else
    objs = []
  end
  objs.size.should == 1
  obj = objs.last
  if (klass == ExternalActivity)
    @external_activity = obj
  end
  # table is a Cucumber::Ast::Table
  attrs.each do |k,expected_value|
    val = obj.send(k)
    # TODO if expected_value is a complex representation, handle it
    if expected_value =~ /^(\[|\{})/
      # handle complex data
      complex_data = JSON.parse(expected_value)
      compare_complex(val, complex_data)
    else
      val.to_s.should == expected_value
    end
  end
end

def compare_complex(obj, complex_data)
  if obj.is_a?(Array)
    complex_data.class.should be Array
    obj.length.should == complex_data.length
    obj.each_with_index do |child, i|
      complex_child = complex_data[i]
      compare_complex(child, complex_child)
    end
  else
    complex_data.class.should be Hash
    complex_data.each do |attr, expected|
      attr_val = obj.send(attr)
      attr_val.to_s.should == expected
    end
  end
end

Then /^the portal should respond with a "([^"]*)" status and location$/ do |status|
  page.status_code.to_s.should == status
  location = page.response_headers["Location"]
  location.should_not be_nil
  location.should match(/http:\/\/www.example.com\/eresources\/\d+/)
end

Then /^the external activity should have a template$/ do
  @external_activity.should_not be_nil
  @external_activity.template.should_not be_nil
end

def publish_activity(name, again)
  login_as('author')
  content = get_activity_definition(name, again)
  page.driver.post(publish_external_activities_url(:version => 'v2'), content)
end

def publish_sequence(name, again)
  login_as('author')
  content = get_sequence_definition(name, again)
  page.driver.post(publish_external_activities_url(:version => 'v2'), content)
end

When /^the external runtime publishes the (sequence|activity) "([^"]*)"( again)?$/ do |kind, name, again|
  if kind == 'activity'
    publish_activity(name, again.nil?)
  elsif kind == 'sequence'
    publish_sequence(name, again.nil?)
  end
end

Given /^the external runtime published the (activity|sequence) "([^"]*)" before$/ do |kind, name|
  if kind == 'activity'
    publish_activity(name, false)
  elsif kind == 'sequence'
    publish_sequence(name, false)
  end
end
