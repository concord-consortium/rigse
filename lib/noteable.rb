#
#  Methods for Objects which have teacher and or author notes...
#
module Noteable  
  
  def teacher_note
    return teacher_notes[0]
  end

  def has_good_teacher_note?
    return teacher_note && teacher_note.body && teacher_note.body.size > 1
  end
  
  def teacher_note_otml
    teacher_note.body.gsub(/\n/,"<br/>")
  end
  
  def teacher_note=(note)
    teacher_notes[0]=note
  end
  
  def author_note
    if author_notes[0]
      return author_notes[0]
    end
  end

  def author_note=(note)
    author_notes[0]=note
  end
end