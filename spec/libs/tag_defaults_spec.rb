require 'spec_helper'

class TagDefaultsClass
  include TagDefaults
end


describe TagDefaults do
  before(:each) do
    @clazz = TagDefaultsClass
    @instance = @clazz.new
  end
  it "should respond to default_tags" do
    @clazz.should respond_to(:default_tags)
  end
end
