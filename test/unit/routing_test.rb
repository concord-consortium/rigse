require File.dirname(__FILE__) + '/../test_helper'

class RoutingTest < ActionController::TestCase 
  def test_recognizes 
    assert_recognizes({"controller" => "investigations", "action" => "index"}, "/investigations") 
    assert_recognizes({"controller" => "otrunk_example/otml_files", "action" => "index"}, "/otrunk_example/otml_files")
    
    # Not a real route anymore.
  end 
end