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

end