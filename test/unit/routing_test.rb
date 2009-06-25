require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < ActionController::TestCase 
  def test_recognizes 
    assert_recognizes({"controller" => "investigations", "action" => "index"}, "/investigations") 
    assert_recognizes({"controller" => "otrunk_example/otrunk_imports", "action" => "index"}, "/otrunk_example_otrunk_imports") 
  end 
end