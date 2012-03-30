class Ccportal::ClassWord < Ccportal::Ccportal
  self.table_name = :portal_class_words
  set_primary_key :class_word_id
  
  belongs_to :course, :foreign_key => :class_id, :class_name => 'Ccportal::Course'

end
