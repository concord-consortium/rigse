module Archiveable
  def can_archive
    self.respond_to?(:is_archived) && self.respond_to?(:is_archived=)
  end

  def attempt_archive(&block)
    if can_archive
      block.call
    else
      raise "#{self.class.name} isn't archivable."
    end
  end

  def archive!
    attempt_archive do
      update_attributes(is_archived: true, archive_date: Time.now)
    end
  end

  def unarchive!
    attempt_archive do
      update_attributes(is_archived: false, archive_date: nil)
    end
  end

  def archived?
    can_archive ? self.is_archived : false
  end

end
