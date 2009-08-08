class Dataservice::ConsoleContent < ActiveRecord::Base
  set_table_name :dataservice_console_contents
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id"
  
  acts_as_list :scope => :console_logger_id
  
end
