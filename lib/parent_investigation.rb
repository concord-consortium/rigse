class ParentInvestigation

  def self.parent_activities()
    activities = Activity.find(:all)
    activities.each do |a|
      parent_activity(a)
    end
  end
  
  
  
  def self.parent_activity(activity)
    return unless activity.investigation.nil?
    i = Investigation.new
    i.name = activity.name
    i.user = activity.user
    i.description = activity.description
    puts "creating investigation #{i.name} : #{i.description}"
    i.save
    activity.investigation = i
    activity.save
  end
  
end
