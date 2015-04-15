# currently this model isn't backed by AR
# Its sole purpose is to clean up searching Report::Learner queries.

class Report::Learner::Selector
  attr_accessor :all_schools, :all_teachers, :all_runnables, :all_perm_forms,
                :select_schools, :select_teachers, :select_runnables, :select_perm_form,
                :start_date, :end_date,
                :learners


  def initialize(options)
    # FIXME this sorting should be done at the end probably because I'm guessing it will
    # cause the query to be run
    @all_schools           = Portal::School.has_teachers.all.sort_by  {|s| s.name.downcase}
    @all_teachers          = Portal::Teacher.all.sort_by {|t| t.name.downcase}

    # TODO: fix me -- choose runnables better
    # I'm also guessing the '+' will cause the query to be run and we might not even
    # need this
    # @all_runnables         = Investigation.published.sort_by { |i| i.name.downcase }
    @all_runnables         = Investigation.published + Investigation.assigned +
                             ::Activity.directly_published + ::Activity.assigned +
                             ExternalActivity.published + ExternalActivity.assigned
    @all_runnables         = @all_runnables.uniq.sort_by { |i| i.name ? i.name.downcase : ""}

    @start_date            = options['start_date']
    @end_date              = options['end_date']
    @all_perm_forms        = Portal::PermissionForm.all.map { |p| p.name }
    begin
      Time.parse(@start_date)
    rescue
      @start_date = nil
    end

    @parsed_end_date = @end_date
    begin
      Time.parse(@end_date + " 23:59:59")
      @parsed_end_date += " 23:59:59"
    rescue
      @parsed_end_date = nil
      @end_date = nil
    end

    @select_runnables      = options['runnables'] || []
    @select_schools        = options['schools']   || []
    @select_teachers       = options['teachers']  || []
    @select_perm_form      = options['perm_form'] || nil

    # to populate dropdown menus:
    @select_schools   = @select_schools.map      { |s| Portal::School.find(s) }
    @select_teachers  = @select_teachers.map     { |t| Portal::Teacher.find(t) }
    @select_runnables = @select_runnables.map    { |r|
      case(r)
      when /^Investigation_(\d+)/
        Investigation.find($1)
      when /^Activity_(\d+)/
        ::Activity.find($1)
      when /^ExternalActivity_(\d+)/
        ExternalActivity.find($1)
      end
    }

    if (@select_schools.size > 0)
      @all_teachers = @all_teachers.select       { |t| @select_schools.map{|s| s.teachers}.flatten.include? t  }
      @select_teachers = @select_teachers.select { |t| @select_schools.map{|s| s.teachers}.flatten.include? t  }
    end

    @scopes = {}
    @scopes[:in_schools]     = @select_schools.map   {|s| s.id}  unless @select_schools.blank?
    @scopes[:with_runnables] = @select_runnables                 unless @select_runnables.blank?
    @scopes[:before]         = Time.parse(@parsed_end_date)      unless @parsed_end_date.blank?
    @scopes[:after]          = Time.parse(@start_date)           unless @start_date.blank?
    @scopes[:with_perm_form] = @select_perm_form                 unless @select_perm_form.blank?

    unless @select_teachers.blank?
      clazzes = @select_teachers.map { |t| t.clazzes }
      clazzes = clazzes.flatten.map    { |c| c.id }
      # if a teacher doesn't have any classes then it is like the filter was not
      # applied, it seems this is intentional but there is no test to document why
      @scopes[:in_classes] = clazzes if clazzes.size > 0
    end

    if @scopes.size > 0
      results = Report::Learner
      @scopes.each_pair do |k,v|
        results = results.send(k,v)
      end
      @learners = results
    else
      @learners = Report::Learner.all
    end
  end

  def runnables_to_report_on
    if select_runnables.blank?
      learners.group('concat(runnable_type, "_", runnable_id)').map{|learner| learner.runnable}
    else
      select_runnables
    end
  end
end

