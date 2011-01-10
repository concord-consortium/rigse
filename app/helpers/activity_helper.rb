
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
    select(activity, :unit_list, count.map{ |c| [ c.name, c.name ]})
  end

  def grade_level_select(activity = :activity)
    count = Activity.grade_level_counts
    select(activity, :grade_level_list, count.map{ |c| [ c.name, c.name] })
    #haml_tag(:p) do
      #haml_concat("grade level select")
    #end
  end

  def subject_area_select(activity = :acvtivity)
    count = Activity.subject_area_counts
    select(activity, :subject_area_list, count.map{ |c| [ c.name, c.name] })
    #haml_tag(:p) do
      #haml_concat("subject area select")
    #end
  end

end
