require 'spec_helper'
class BaseClass
  attr_accessor :spy
  def clone(opts ={})
    spy.clone
    return opts
  end
end

class CloneableClass < BaseClass
  include Cloneable
end
class CloneableWithAttrbiutes < BaseClass
  include Cloneable
  cloneable_associations :one, :two, :three
end


describe CloneableClass do
  describe "without any custom cloneable_associations" do
    before(:each) do 
      @clazz = CloneableClass
      @instance = @clazz.new
      @instance.spy = Object.new
    end
    
    it "should clone without errors" do
      lambda { @instance.clone()}.should_not raise_error
    end
    it "should have it's own clone method called" do
      @instance.spy.should_receive :clone
      @instance.clone
    end
    it "should not add new clone includes" do
      @instance.clone().should_not include(:include)
    end
  end

  describe "with local class method #cloneable_associations" do
    before(:each) do 
      @clazz = CloneableWithAttrbiutes
      @instance = @clazz.new
      @instance.spy = Object.new
    end
  
    it "should have a class method called cloneable_associations" do
      @clazz.should respond_to(:cloneable_associations)
    end
    it "should clone without errors" do
      lambda { @instance.clone()}.should_not raise_error
    end
    it "should have it's own clone method called" do
      @instance.spy.should_receive :clone
      @instance.clone
    end
  
  end
end
