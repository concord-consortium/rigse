class Dataservice::BundleLogger < ActiveRecord::Base
  set_table_name :dataservice_bundle_loggers
  
  has_one  :learner, :class_name => "Portal::Learner"
  has_many :bundle_contents, :class_name => "Dataservice::BundleContent", :order => :position, :dependent => :destroy
  
  has_one :last_non_empty_bundle_content, 
    :class_name => "Dataservice::BundleContent",
    :conditions => "empty is null and valid_xml is not null",
    :order => 'position DESC' 
  

  OPEN_ELEMENT_EPORTFOLIO = "<sailuserdata:EPortfolio xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:sailuserdata=\"sailuserdata\">\n"
  CLOSE_ELEMENT_EPORTFOLIO = "\n</sailuserdata:EPortfolio>"
end
