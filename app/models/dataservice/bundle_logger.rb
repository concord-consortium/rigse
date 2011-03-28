class Dataservice::BundleLogger < ActiveRecord::Base
  set_table_name :dataservice_bundle_loggers
  
  has_one    :learner, :class_name => "Portal::Learner"
  belongs_to :in_progress_bundle, :class_name => "Dataservice::BundleContent"
  has_many   :bundle_contents, :class_name => "Dataservice::BundleContent", :order => :position, :dependent => :destroy
  

  has_one :last_non_empty_bundle_content, 
    :class_name => "Dataservice::BundleContent",
    :conditions => "empty is false and valid_xml is true",
    :order => 'position DESC' 

  # This was the query, which was confusing:
  #has_one :last_non_empty_bundle_content, 
    #:class_name => "Dataservice::BundleContent",
    #:conditions => "empty is null and valid_xml is not null",
    #:order => 'position DESC' 

  OPEN_ELEMENT_EPORTFOLIO = "<sailuserdata:EPortfolio xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:sailuserdata=\"sailuserdata\">\n"
  CLOSE_ELEMENT_EPORTFOLIO = "\n</sailuserdata:EPortfolio>"
  
  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 5
  
  self.extend SearchableModel
  
  @@searchable_attributes = %w{updated_at}
  
  class <<self

    def convert_nulls_in_bundle_content_fields
      empty_count = 0
      valid_count = 0
      Self.find(:all, :conditions => "empty is null").each do |i| 
        i.empty = "false" 
        i.save 
        empty_count = empty_count + 1
      end
      Self.find(:all, :conditions => "valid_xml is null").each do |i| 
        i.xml = "false" 
        i.save
        valid_count = valid_count + 1
      end
      logger.info("Converted #{empty_count} bundle contents with null empty values")
      logger.info("Converted #{valid_count} bundle contents with null valid_xml values")
    end

    def searchable_attributes
      @@searchable_attributes
    end

    def display_name
      "Dataservice::BundleLogger"
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
      "#{user.login}: (#{user.name}), #{runnable_name}, #{self.bundle_contents.count} sessions"
    else
      "no associated learner"
    end
  end
  
  def extract_saveables
    self.bundle_contents.each { |bc| bc.extract_saveables }
  end
  
  def extract_open_responses
    self.bundle_contents.each { |bc| bc.extract_open_responses }
  end
  
  def extract_multiple_choices
    self.bundle_contents.each { |bc| bc.extract_multiple_choices }
  end
  
  def start_bundle
    self.in_progress_bundle ||= Dataservice::BundleContent.create(:bundle_logger => self)
    self.save
    self.reload
  end

  def end_bundle(attributes = {})
    # should it be an error to receive end_bundle
    # with no in_progress_bundle?
    if (self.in_progress_bundle.nil?)
      logger.info("end_bundle called without in_progress_bundle")

      # if an id is specified, we know we have a problem:
      if attributes[:id] != nil
        raise "id specified, but no in_progress_bundle defined"
      end
      self.in_progress_bundle = Dataservice::BundleContent.new({:bundle_logger => self})
    end
    # force processing
    self.in_progress_bundle.attributes = attributes.merge(:processed => false)
    self.in_progress_bundle.save!
    self.in_progress_bundle = nil
  end

end
