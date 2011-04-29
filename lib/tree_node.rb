#
#  Methods for Objects which are part of the Investigations tree structure
#
module TreeNode
  
  def child_after(child)
    index = children.index(child)
    if index
      return children[index+1]
    end
    return nil
  end
  
  def child_before(child)
    index = children.index(child)
    if index && (index > 0)
      return children[index-1]
    end
    return nil
  end
  
  def next
    if parent
      return parent.child_after(self)
    end
    return nil
  end
  
  def previous
    if parent
      return parent.child_before(self)
    end
    return nil
  end

  def number
    if parent
      return parent.children.index(self) + 1
    end
    return 1
  end
  
  def each(&block)
    block[self]
    self.children.each do |leaf| 
      if leaf.respond_to? 'children'
        leaf.each(&block) 
      else
        block.call(leaf)
      end
    end
  end
  
  # TODO, this should probably go into a container module.
  # However, sense it relies on TreeNode methods, it also
  # makes some sense to put here...
  def deep_set_user(new_user, logging=false)
    original_user = self.user
    set_user = lambda { |thing|
      unless thing.user == new_user
        old_login = thing.user ? thing.user.login : "<nil>"
        puts "changing ownership of #{thing.name} from #{old_login} to #{new_user.login}" if logging
        thing.user = new_user
        thing.save
      end
      # TODO: See page.rb about returning page_elements intead of embeddables
      # in the children method. Probably a better approach.
      if thing.class == Page
        thing.page_elements.each do |pe|
          if pe.user != new_user
            pe.user = new_user
            pe.save
          end
        end
      end
      if thing.respond_to? 'teacher_notes'
        thing.teacher_notes.each do |note|
          unless note.user == new_user
            old_login = note.user ? note.user.login : "<nil>"
            puts "changing ownership of #{note} from #{old_login} to #{new_user.login}" if logging
            note.user = new_user
            note.save
          end
        end
      end
      if thing.respond_to? 'author_notes'
        thing.author_notes.each do |note|
          unless note.user == new_user
            puts "changing ownership of #{note} from #{note.user} to #{new_user}" if logging
            note.user = new_user
            note.save
          end
        end
      end

    }
    
    set_user.call(self)    
    self.each &set_user
    
    
    if original_user
      unless original_user == new_user
        original_user.removed_investigation
      end
    end
  end
  
  
end