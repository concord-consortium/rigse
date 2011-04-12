module PagesHelper
  # show teacher notes if this is the first page of the section.
  def should_show_teacher_notes?(page)
    if page.has_good_teacher_note? 
      return true
    end
    [:investigation,:activity,:section].each do |container|
      if should_show_teacher_note? page,container
        return true
      end
    end
    false
  end
  
  def should_show_teacher_note?(page,meth_sym)
    container = page.send meth_sym
    if container && container.has_good_teacher_note?
      if page.section && page.section.pages.first == page
        case container.class
          when Investigation
            return container.activities.first == page.activity
          when Activity
            return container.sections.first == page.section
          else
            return true
        end
      end
    end
    return false
  end
  
  def should_show_snapshot_button?(embeddable)
    return embeddable.respond_to? :snapshotable?
  end
  
end
