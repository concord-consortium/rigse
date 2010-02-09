class Report::Offering::Section
  
  attr_accessor :activity_report, :offering, :section, :pages, :saveables, :learners
  
  def initialize(activity_report, offering, section)
    @activity_report = activity_report
    @offering = offering
    @learners = @offering.learners
    
    @section = section
    @pages = @section.pages.collect { |page| Report::Offering::Page.new(self, @offering, page) }
  end
  
  def respondables(klazz=nil)
    @pages.collect { |page_report| page_report.respondables(klazz) }.flatten
  end

end