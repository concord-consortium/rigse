require 'digest'

module ResearcherDashboard
  # What rigse knows about a class scope, computed from its own tables: the facts the
  # metadata endpoint returns, the assignment list the run path hands the VM, and the URL
  # list the profile refresh hands the deriver. One object computes all three, so the
  # fingerprint the app compares and the fingerprint a refresh records cannot disagree.
  class Scope
    FINGERPRINT_VERSION = 'v1'.freeze
    # report-service's /derive-profile limits. A request over them is refused there, so it
    # is refused here instead, with a reason, before anything is sent.
    DERIVE_MAX_URLS = 500
    DERIVE_MAX_URL_LENGTH = 2048
    DERIVE_MAX_BODY_BYTES = 256 * 1024

    attr_reader :clazz

    def initialize(clazz)
      @clazz = clazz
    end

    # One entry per offering of an external activity, in the class's own order. The URL is
    # the stored column, never ExternalActivity#url, which re-serializes it (lowercasing the
    # scheme, dropping a default port). Offerings of any other runnable_type are skipped:
    # loading a runnable whose model is gone raises NameError. Inactive offerings are
    # included, since their student data exists.
    def assignments
      @assignments ||= clazz.offerings
        .where(runnable_type: 'ExternalActivity')
        .order(:id)
        .includes(runnable: :tool)
        .filter_map do |offering|
          activity = offering.runnable
          next unless activity
          {
            offering_id: offering.id,
            runnable_id: activity.id,
            name: activity.name,
            url: activity.read_attribute(:url),
            # For display only; nothing matches on it.
            tool: activity.tool&.name
          }
        end
    end

    # What the VM writes into scope.json, which carries no tool.
    def run_assignments
      assignments.map { |a| a.except(:tool) }
    end

    # Changes when an offering is added or removed or its URL changes. JSON rather than a
    # joined string so no URL can imitate a separator; versioned so a later shape forces
    # one refresh everywhere rather than comparing unlike values.
    def fingerprint
      pairs = assignments.map { |a| [a[:offering_id], a[:url]] }.sort_by(&:first)
      "#{FINGERPRINT_VERSION}:#{Digest::SHA256.hexdigest(JSON.generate(pairs))}"
    end

    # The body of POST /derive-profile. rigse supplies the list and never fetches, parses or
    # normalizes it, which is what keeps the deriver from taking a URL from anyone else. A
    # URL too long for the deriver is left out rather than denying the class a profile; a
    # list too large is refused whole, since a truncated profile would silently hide packages.
    def derive_profile_body
      urls = assignments.map { |a| a[:url] }
        .select { |url| url.present? && url.length <= DERIVE_MAX_URL_LENGTH }
        .uniq.sort
      if urls.size > DERIVE_MAX_URLS
        raise Refusal.new(422, "This class has #{urls.size} distinct assignment URLs, more than the #{DERIVE_MAX_URLS} a profile can be derived from")
      end
      body = { class_hash: clazz.class_hash, assignment_fingerprint: fingerprint, assignment_urls: urls }
      # Bytes rather than characters: never smaller than the function's character count.
      if JSON.generate(body).bytesize > DERIVE_MAX_BODY_BYTES
        raise Refusal.new(422, "This class's assignment URLs exceed the #{DERIVE_MAX_BODY_BYTES / 1024} KiB a profile can be derived from")
      end
      body
    end

    def teachers
      clazz.teachers.includes(:user).order(:id).map do |teacher|
        { id: teacher.user_id, name: "#{teacher.user.first_name} #{teacher.user.last_name}".strip }
      end
    end

    # The cohorts of the class's teachers, through the join User#with_teacher_clazzes makes,
    # so "the projects this class belongs to" means what the researcher gate means.
    def cohorts
      @cohorts ||= Admin::Cohort
        .joins("INNER JOIN admin_cohort_items __aci ON __aci.admin_cohort_id = admin_cohorts.id AND __aci.item_type = 'Portal::Teacher'")
        .joins("INNER JOIN portal_teacher_clazzes __ptc ON __ptc.teacher_id = __aci.item_id")
        .where("__ptc.clazz_id = ?", clazz.id)
        .distinct
        .order(:id)
        .to_a
    end

    def project_ids
      cohorts.map(&:project_id).compact.uniq.sort
    end
  end
end
