module TeacherNotesHelper
  def domain_select(note)
    collection_select :person, :job_ids,
      Domain.find(:all),
      :id, 
      :name,
      {},
      :multiple => true,
      :name => 'teacher_note[domain_ids][]' 
  end
end
