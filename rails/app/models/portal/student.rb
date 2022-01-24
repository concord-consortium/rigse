class Portal::Student < ApplicationRecord
  self.table_name = :portal_students

  acts_as_replicatable

  belongs_to :user, :class_name => "User", :foreign_key => "user_id", :inverse_of => :portal_student
  belongs_to :grade_level, :class_name => "Portal::GradeLevel", :foreign_key => "grade_level_id"

  # because of has many polymorphs, we don't need the following relationships defined
  # TODO: Schools must be queried through clazzes.
  # TODO: For now we are writing custom methods...
  # has_many :school_memberships, :as => :member, :class_name => "Portal::SchoolMembership"
  # has_many :schools, :through => :school_memberships, :class_name => "Portal::School"

  has_many :learners, :dependent => :destroy , :class_name => "Portal::Learner", :foreign_key => "student_id"
  has_many :report_learners, :class_name => "Report::Learner"
  has_many :student_clazzes, :dependent => :destroy, :class_name => "Portal::StudentClazz", :foreign_key => "student_id"

  has_many :clazzes, :through => :student_clazzes, :class_name => "Portal::Clazz"
  has_many :teachers, -> { distinct }, :through => :clazzes, :class_name => "Portal::Teacher"
  # students cohorts are infered from its teacher(s)
  has_many :cohorts, -> { distinct }, :through => :teachers, :class_name => "Admin::Cohort"
  has_many :projects, -> { distinct }, :through => :cohorts, :class_name => "Admin::Project"

  has_many :own_collaborations, :class_name => "Portal::Collaboration", :foreign_key => "owner_id"
  has_many :collaboration_memberships, :class_name => "Portal::CollaborationMembership"
  has_many :collaborations, :through => :collaboration_memberships, :class_name => "Portal::Collaboration"

  has_many :portal_student_permission_forms, :dependent => :destroy, :class_name => "Portal::StudentPermissionForm", :foreign_key => "portal_student_id"

  has_many :permission_forms,
    :through      => :portal_student_permission_forms,
    :class_name   => "Portal::PermissionForm",
    :source       => :portal_permission_form,
    :after_add    => :update_report_permissions,
    :after_remove => :update_report_permissions

  [:name, :first_name, :last_name, :email, :login, :anonymous?, :has_role?].each { |m| delegate m, :to => :user }

  include Changeable


  def self.generate_user_email
    hash = UUIDTools::UUID.timestamp_create.to_s
    "no-email-#{hash}@concord.org"
  end

  def self.generate_user_login(first_name, last_name)

    suggested_login =   "#{first_name.downcase.gsub(/[^\p{L}\d]/,'')[0..0]}" +
                        "#{last_name.downcase.gsub(/[^\p{L}\d]/,'')}"


    counter = 0
    generated_login = suggested_login

    # Disable cache as we have higher chance to avoid race condition causing that the generated login
    # is not unique. Also it's needed when we actually handle that situation (see student_registration.rb),
    # as otherwise subsequent login generation could return the same result as previous call.
    ApplicationRecord.uncached do
      while (User.login_exists? generated_login)
        counter = counter + 1
        generated_login = "#{suggested_login}#{counter}"
      end
    end

    return generated_login
  end

  def status(offerings_updated_after=0)
    # If offerings_updated_after is provided, all the offerings that haven't been updated
    # after this timestamp will be filtered out from the results (performance optimization).
    offerings_updated_after = Time.at(offerings_updated_after.to_i)
    # Theoretically these queries could be merged into single one, but then
    # ActiveRecord complains about eager loading of polymorphic association (:runnable).
    learners_ids = Portal::Learner.joins(:report_learner)
                                  .where('portal_learners.student_id = ?', self.id)
                                  .where('report_learners.last_run > ?', offerings_updated_after)
                                  .pluck(:id)
    if learners_ids.length > 0
      report_learners = Portal::Learner.includes({offering: {runnable: :template}}, :report_learner, :learner_activities)
                                       .where(id: learners_ids)
                                       .map do |learner|
      student_status = Report::OfferingStudentStatus.new
      student_status.student = self
      student_status.learner = learner
      student_status.offering = learner.offering
      {
        :offering_id => student_status.offering.id,
        :last_run => student_status.last_run_string,
        :complete_percent => student_status.complete_percent,
        :subsection_complete_percent => student_status.sub_sections.map do |activity|
          student_status.activity_complete_percent(activity)
        end
      }
      end
    else
      report_learners = []
    end
    {
      timestamp: Time.now.to_i,
      report_learners: report_learners
    }
  end

  def update_report_permissions(permission_form)
    report_learners.each { |l| l.update_permission_forms; l.save }
    learners.each { |l| l.update_report_model_cache(true) }
  end

  ## TODO: fix with has_many finderSQL
  def schools
    schools = self.clazzes.map {|c| c.school }.uniq.flatten.compact
  end

  def school
    return schools.last
  end

  def has_teacher?(teacher)
    self.teachers.include?(teacher)
  end

  ##
  ## Strange approach to alter the behavior of Clazz.children()
  ## to reflect a student-centric world view.
  ## ... (possibly a bad idea?)
  module FixupClazzes
    def children
      return offerings
    end
  end

  ##
  ## required for the accordion view
  ##
  def children
    clazzes.to_a.map! {|c| c.extend(FixupClazzes)}
  end

  def process_class_word(class_word)
    if clazz = Portal::Clazz.find_by_class_word(class_word)
      unless self.student_clazzes.find_by_clazz_id(clazz.id)
        self.student_clazzes.create!(:clazz_id => clazz.id, :student_id => self.id, :start_time => Time.now)
      end
    else
      nil
    end
  end

  def has_clazz?(clazz)
    self.clazzes.detect { |cl| cl.id == clazz.id }
  end

  def active_clazzes
    Portal::Clazz
      .joins(:student_clazzes)
      .where(is_archived: false )
      .where(student_clazzes: { student_id: id })
      .uniq
  end

  def add_clazz(clazz)
    unless self.has_clazz?(clazz)
      self.clazzes << clazz
    end
  end

  def remove_clazz(clazz)
    self.clazzes.delete clazz
  end

  def move_student_and_return_config(new_class, current_class)
    # initialize JSON for report API call
    report_config = {
      new_class_info_url: new_class.class_info_url(URI.parse(APP_CONFIG[:site_url]).scheme, URI.parse(APP_CONFIG[:site_url]).host),
      new_context_id: new_class.class_hash.to_s,
      old_context_id: current_class.class_hash.to_s,
      platform_id: APP_CONFIG[:site_url].to_s,
      platform_user_id: user_id.to_s
    }
    assignments = []

    # find matches between student learners and new class's offerings. Update offering_id values to match those in new class (student work on assignments that aren't assigned to new class becomes orphaned)
    learners.each do |sa|
      new_class.offerings.each do |nca|
        if sa.offering.runnable == nca.runnable
          learner_to_update = Portal::Learner.find(sa.id)
          learner_to_update.update_attribute('offering_id', nca.id)
          learner_to_update.update_report_model_cache
          # add assignment to JSON for report API call
          assignments << {
            new_resource_link_id: nca.id.to_s,
            old_resource_link_id: sa.offering_id.to_s,
            tool_id: nca.runnable.tool&.tool_id
          }
        end
      end
    end

    # add learner IDs to JSON for report API
    report_config[:assignments] = assignments
    report_config
  end

end
