require 'spec_helper'
require 'views/shared_examples/projects_listing_spec'

describe "/investigations/edit.html.haml" do
  before(:each) do
    @investigation = Factory.build(:investigation)
  end

  include_examples 'projects listing'
end