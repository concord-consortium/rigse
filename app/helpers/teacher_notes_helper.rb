module TeacherNotesHelper
  def domain_select(note)
    collection_select :teacher_note, :domain_ids,
      RiGse::Domain.all,
      :id, 
      :name,
      {},
      :multiple => true,
      :name => 'teacher_note[domain_ids][]' 
  end

  def grade_spans
    RiGse::GradeSpanExpectation.grade_spans
  end
  
  def domains
    RiGse::Domain.all
  end
    
end
