#
# This is a denormalized class. Its used to store summary data for
# learners as would be used in a report.

class Report::Learner < ApplicationRecord
  self.table_name = "report_learners"

  belongs_to   :learner, :class_name => "Portal::Learner", :foreign_key => "learner_id",
    :inverse_of => :report_learner
  belongs_to   :student, :class_name => "Portal::Student"
  belongs_to   :runnable, :polymorphic => true

  scope :after,  lambda         { |date|         where("last_run > ?", date)  }
  scope :before, lambda         { |date|         where("last_run < ?", date) }
  scope :in_schools, lambda     { |school_ids|   where(:school_id   => school_ids) }
  scope :in_classes, lambda     { |class_ids|    where(:class_id    => class_ids) }

  scope :with_permission_ids, lambda { |ids|
    includes(student: :portal_student_permission_forms)
      .where("portal_student_permission_forms.portal_permission_form_id" => ids)

  }

  scope :with_runnables, lambda { |runnables|
    where 'CONCAT(runnable_type, "_", runnable_id) IN (?)', runnables.map{|runnable| "#{runnable.class}_#{runnable.id}"}}

  validates_presence_of   :learner
  validates_uniqueness_of :learner_id

  after_create :update_fields
  before_save :ensure_no_nils

  def ensure_no_nils
    %w{offering_name teachers_name student_name class_name school_name runnable_name}.each do |attr|
      cur_val = self.send(attr)
      self.send("#{attr}=", "") if cur_val.nil?
    end
    return true
  end

  def serialize_blob_answer(answer)
    if answer.is_a? Hash
      blob = answer[:blob]
      if blob
        # Return a serialized hash of the blob
        return {
            :type => "Dataservice::Blob",
            :id => blob.id,
            :token => blob.token,
            :file_extension => blob.file_extension,
            :note => answer[:note]
        }
      end
    end
    # Otherwise don't change it
    return answer
  end

  def last_run_string(opts={})
    return Report::Learner.build_last_run_string(last_run, opts)
  end

  def self.build_last_run_string(last_run, opts={})
    not_run_str = "Not yet started"   || opts[:not_run]
    prefix      = "Started, last run" || opts[:prefix]
    format      = "%b %d, %Y"         || opts[:format]

    return not_run_str if !last_run
    return "#{prefix} #{last_run.strftime(format)}"
  end

  def calculate_last_run
    # RAILS6 TODO: figure out alternative? - this was using the now removed dataservice model update times
    return self.last_run
  end

  def self.encode_answer_key(item)
    "#{item.class.to_s}|#{item.id}"
  end

  def self.decode_answer_key(answer_key)
    answer_key.split("|")
  end

  def update_field(methods_string, field=nil)
    value = nil
    unless field
      field =methods_string.split(".")[-2..2].join("_")
    end
    begin
      symbols = methods_string.split(".").map{ |s| s.to_sym}
      value = symbols.inject(self.learner) do |o,symbol|
        o.send(symbol)
      end
      if block_given?
        value = yield(value)
      end
      self.send("#{field}=".to_sym,value)
    rescue
      Rails.logger.error("could not set self.#{field} using self.learner.#{methods_string} #{$!}!")
    end
  end

  def update_fields
    update_field "student.id"
    update_field "offering.id"
    update_field "offering.name"

    update_field "offering.runnable.name"
    update_field "offering.runnable.id"
    update_field "offering.runnable.class.to_s", "runnable_type"

    update_field "student.user.id"
    update_field "student.user.name", "student_name"
    update_field "student.user.login", "username"

    update_field "offering.clazz.id", "class_id"
    update_field "offering.clazz.name", "class_name"
    update_field "offering.clazz.school.name", "school_name"
    update_field "offering.clazz.school.id",    "school_id"

    update_teacher_info_fields

    update_permission_forms

    calculate_last_run

    Rails.logger.debug("Updated Report Learner: #{self.student_name}")
    self.save
  end

  def escape_comma(string)
    string.gsub(',', ' ')
  end

  def update_teacher_info_fields
    update_field("offering.clazz.teachers", "teachers_name") do |ts|
      ts.map{ |t| escape_comma(t.user.name) }.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_district") do |ts|
      ts.map{ |t| t.schools.map{ |s| escape_comma(s.district.name)}.join(", ")}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_state") do |ts|
      ts.map{ |t| t.schools.map{ |s| escape_comma(s.district.state)}.join(", ")}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_email") do |ts|
      ts.map{ |t| escape_comma(t.user.email)}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_id") do |ts|
      ts.map{ |t| t.id}.join(", ")
    end
    update_field("offering.clazz.teachers", "teachers_map") do |ts|
      ts.map{ |t| "#{t.id}: #{escape_comma(t.user.name)}"}.join(", ")
    end

  end

  def update_permission_forms
    update_field("student.permission_forms", "permission_forms") do |pfs|
      pfs.map{ |p| escape_comma(p.fullname) }.join(",")
    end
    update_field("student.permission_forms", "permission_forms_id") do |pfs|
      pfs.map{ |p| p.id }.join(",")
    end
    update_field("student.permission_forms", "permission_forms_map") do |pfs|
      pfs.map{ |p| "#{p.id}: #{escape_comma(p.fullname)}" }.join(",")
    end
  end
end
