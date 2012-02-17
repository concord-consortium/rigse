
module ActivityHelper

  # !green = #A3BDA2
  # !middleschool = !green
  # !salmon = #C6958B
  # !highschool = !salmon
  # !mint_green = #D4EBD2
  # !math = !mint_green
  # !orange_brown = #BA9C61
  # !probe = !orange_brown
  # !yellow = #D6C754
  # !my = !yellow

  def green  ; '#A3BDA2'; end
  def salmon ; '#C6958B'; end
  def orange ; '#BA9C61'; end
  def yellow ; '#D6C754'; end

  def style_for_activity_key(key)
    case key
    when /high/i
      return "background-color: #{salmon};"
    when /middle/i
      return "background-color: #{green};"
    end
    return "background-color: #{yellow};"
  end

  def unit_select(activity = :activity)
    count = Activity.unit_counts
    select(activity, :unit_list, count.map{ |c| [ c.name, c.name ]}, {:include_blank => 'None'})
  end

  def grade_level_select(activity = :activity)
    count = Activity.grade_level_counts
    select(activity, :grade_level_list, count.map{ |c| [ c.name, c.name] }, {:include_blank => 'None'})
    #haml_tag(:p) do
      #haml_concat("grade level select")
    #end
  end

  def subject_area_select(activity = :activity)
    count = Activity.subject_area_counts
    select(activity, :subject_area_list, count.map{ |c| [ c.name, c.name] }, {:include_blank => 'None'})
    #haml_tag(:p) do
      #haml_concat("subject area select")
    #end
  end

  def activity_sensor_and_model_summary(activity)
    summary = activity.probe_and_model_summary
    labels = { :probes => "Sensor", :models => "Model"}
    sarray = []
    summary.each{ |key, values|
      next if values.blank?
      label = labels[key]
      label = label.pluralize if values.size > 1
      sarray << ("#{label}: #{values.join(', ')}")
    }
    return "" if sarray.empty?
    "(#{sarray.join('; ')})"
  end
  
  def activity_status_options
    status_options = ["private", "published"]
    status_options << "archived" if current_user.has_role?('admin')
    status_options
  end
end
