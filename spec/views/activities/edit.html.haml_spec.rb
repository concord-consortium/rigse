require 'spec_helper'
require 'views/shared_examples/projects_listing_spec'

describe "/activities/edit.html.haml" do
  before(:each) do
    @activity = Factory.build(:activity)
  end

  include_examples 'projects listing'
end