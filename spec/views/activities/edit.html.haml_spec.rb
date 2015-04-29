require 'spec_helper'

describe "/activities/edit.html.haml" do
  before(:each) do
    @activity = Factory.build(:activity)
  end

  include_examples 'projects listing'
end