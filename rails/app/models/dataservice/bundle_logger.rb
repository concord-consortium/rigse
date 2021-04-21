class Dataservice::BundleLogger < ApplicationRecord
  self.table_name = :dataservice_bundle_loggers

  has_one    :learner, :class_name => "Portal::Learner"
  belongs_to :in_progress_bundle, :class_name => "Dataservice::BundleContent"
  has_many   :bundle_contents, -> {order :position}, :class_name => "Dataservice::BundleContent", :dependent => :destroy

  has_many :launch_process_events, -> {order 'id ASC'}, :class_name => "Dataservice::LaunchProcessEvent", :through => :bundle_contents

  has_one :last_non_empty_bundle_content, -> { where("empty is false and valid_xml is true").order('position DESC') },
    :class_name => "Dataservice::BundleContent"

  OPEN_ELEMENT_EPORTFOLIO = "<sailuserdata:EPortfolio xmi:version=\"2.0\" xmlns:xmi=\"http://www.omg.org/XMI\" xmlns:sailuserdata=\"sailuserdata\">\n"
  CLOSE_ELEMENT_EPORTFOLIO = "\n</sailuserdata:EPortfolio>"

  include Changeable

  # pagination default
  cattr_reader :per_page
  @@per_page = 5

  self.extend SearchableModel

  @@searchable_attributes = %w{updated_at}

  class << self

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
    self.bundle_contents << self.in_progress_bundle
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
      self.start_bundle
    end
    # force processing
    self.in_progress_bundle.attributes = attributes.merge(:processed => false)
    self.in_progress_bundle.save!
    self.in_progress_bundle = nil
    self.save
  end

end
