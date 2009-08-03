class Portal::Learner < ActiveRecord::Base
  set_table_name :portal_learners
  
  acts_as_replicatable
  
  has_one :sds_config, :class_name => "Portal::SdsConfig", :as => :configurable
  
  belongs_to :student, :class_name => "Portal::Student", :foreign_key => "student_id"
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  
  belongs_to :console_logger, :class_name => "Dataservice::ConsoleLogger", :foreign_key => "console_logger_id"
  belongs_to :bundle_logger, :class_name => "Dataservice::BundleLogger", :foreign_key => "bundle_logger_id"
  
  [:name, :first_name, :last_name, :email, :vendor_interface].each { |m| delegate m, :to => :student }

  after_create do |learner|
    learner.console_logger = Dataservice::ConsoleLogger.create!
    learner.bundle_logger = Dataservice::BundleLogger.create!
  end

  # ###################################################
  # ### SDS Specific code
  # ###################################################
  # after_create :create_sds_counterpart
  # 
  # # Find or creates a learner for this sds runnable object
  # # and for the specified user.
  # def create_sds_counterpart
  #   wid = Portal::SdsConnect::Connect.create_workgroup(self.student.user.name, self.offering.sds_config.sds_id)
  #   config = self.create_sds_config(:sds_id => wid)
  #   Portal::SdsConnect::Connect.create_workgroup_membership(wid, [self.student.user.sds_config.sds_id])
  #   config
  # end
  # 
  # def sds_config_url(options = {})
  #   conn = Portal::SdsConnect::Connect
  #   options.merge({:savedata => false, :nobundles => false, :author => false}) {|k,o,n| o}
  #   
  #   config_url = "#{conn.offering_url(self.offering.sds_config.sds_id)}/config/#{self.sds_config.sds_id}/0"
  #   
  #   if options[:savedata] != true
  #     config_url << "/view"
  #   end
  #   options.delete(:savedata)
  #   
  #   if options[:nobundles] == true
  #     config_url << "/nobundles"
  #   end
  #   options.delete(:nobundles)
  #   
  #   if options[:author] == true
  #     options["otrunk.view.author"] = true
  #     options.delete(:author)
  #   end
  #   
  #   if options.size > 0
  #   options_arr = []
  #     options.each do |k,v|
  #       options_arr << "#{k}=#{v}"
  #     end
  #     options_str = options_arr.join("&")
  #   
  #     config_url << "?"
  #     config_url << options_str
  #   end
  #   config_url
  # end
  # 
  # ###################################################
  # ### End SDS Specific code
  # ###################################################
  
end