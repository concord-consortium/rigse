module ActivityStepsHelper
  
  def form_for_step(act_step)
    type = act_step.step_type
    case type
    when 'Xhtml'
      act_step.step.name
    when 'MultipleChoice'
      act_step.step.prompt
    when 'OpenResponse'
      act_step.step.prompt
    end
  end
  
end
