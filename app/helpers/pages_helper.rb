module PagesHelper

  
  def element_types
    [DataCollector,DrawingTool,OpenResponse,Xhtml,MultipleChoice,DataTable,MwModelerPage,NLogoModel]
  end

  def page_acceptable_types
    element_types.map {|t| t.name.underscore}
  end
  
end
