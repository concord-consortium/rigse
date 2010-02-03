
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

end
