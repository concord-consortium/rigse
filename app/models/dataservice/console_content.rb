class Dataservice::ConsoleContent < ActiveRecord::Base
  set_table_name :dataservice_console_contents
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id"
  
  acts_as_list :scope => :console_logger_id
  
  include SailBundleContent
  
  # pagination default
  cattr_reader :per_page
  @@per_page = 5

  self.extend SearchableModel
  
  @@searchable_attributes = %w{body console_logger_id}
  class <<self
    
    def searchable_attributes
      @@searchable_attributes
    end

  end

  def session_uuid
    return nil if self.body.nil?
    return self.body[/net.sf.sail.emf.launch.SessionBundleHelper.setupSessionBundle: sessionId: ([^&"]*)/,1]
  end

  
end
