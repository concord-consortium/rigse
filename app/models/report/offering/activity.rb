class Report::Offering::Activity

  attr_accessor :investigation_report, :offering, :activity, :sections, :embeddables, :saveables, :learners
  
  def initialize(investigation_report, offering, activity)
    @investigation_report = investigation_report
    @offering = offering
    @learners = @offering.learners
    
    @activity = activity
    @sections = @activity.sections.collect { |section| Report::Offering::Section.new(self, @offering, section) }
  end
  
  def respondables(klazz=nil)
    @sections.collect { |section_report| section_report.respondables(klazz) }.flatten
  end
  
end