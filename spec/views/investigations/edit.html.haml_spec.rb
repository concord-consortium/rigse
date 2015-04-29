require 'spec_helper'

describe "/investigations/edit.html.haml" do
  before(:each) do
    @investigation = Factory.build(:investigation)
  end

  include_examples 'projects listing'
end