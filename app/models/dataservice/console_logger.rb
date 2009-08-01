class Dataservice::ConsoleLogger < ActiveRecord::Base
  set_table_name :dataservice_console_loggers
  
  has_one  :learner, :class_name => "Portal::Learner"
  has_many :console_contents, :class_name => "Dataservice::ConsoleContent", :order => :position, :dependent => :destroy
end
