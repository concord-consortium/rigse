class Dataservice::ConsoleLogger < ActiveRecord::Base
  self.table_name = :dataservice_console_loggers
  
  has_one  :learner, :class_name => "Portal::Learner"
  has_many :console_contents, :class_name => "Dataservice::ConsoleContent", :order => :position, :dependent => :destroy
  has_one :last_console_content, 
    :class_name => "Dataservice::ConsoleContent",
    :order => 'position DESC' 

  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 5
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{updated_at}
  
  class <<self
    def searchable_attributes
      @@searchable_attributes
    end

  end

  # for the view system ...
  def user
    nil
  end
  
  def name
    if learner = self.learner
      user = learner.student.user
      name = user.name
      login = user.login
      runnable_name = (learner.offering.runnable ? learner.offering.runnable.name : "invalid offering runnable")
      "#{user.login}: (#{user.name}), #{runnable_name}, #{self.console_contents.count} sessions"
    else
      "no associated learner"
    end
  end

end
