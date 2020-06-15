class Report::Offering::Page
  
  attr_accessor :offering, :learners, :page
  
  def initialize(section_report, offering, page)
    @section_report = section_report
    @offering = offering
    @learners = @offering.learners
    @page = page
    
    @respondables = []

    @page.saveable_types.each do |saveable_type|
      association = saveable_type.to_s.demodulize.underscore
      embeddables = @page.send("#{association}s").collect
      embeddables.each do |embeddable|
        saveables = embeddable.saveables.by_offering(@offering)
        if saveables.empty?
          @respondables += [Saveable::RespondableProxy.new(embeddable)]
        else
          @respondables += saveables.collect { |saveable| Saveable::RespondableProxy.new(saveable) }
        end
      end
    end
  end

  def respondables(klazz=nil)
    if klazz
      @respondables.select { |r| r.respondable_class == klazz }
    else
      @respondables
    end
  end
end