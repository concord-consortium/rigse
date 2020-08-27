#
#  Methods for Objects which have teacher and or author notes...
#
module Noteable

  def author_note
    return author_notes[0]
  end

  def author_note=(note)
    author_notes[0]=note
  end

end
