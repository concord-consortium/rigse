##
## This modules supports ideas of heritage. Classes the extend this module
## wil be blessed with an ancestor, and descendants.
##
module HasPedigree

  ##
  ## Called when a class is extended by this module
  ##
  def self.included(clazz)
    ## add before_save hooks
    clazz.class_eval {
      has_many :ancestors_ancestries, :class_name => "Ancestry", :as => :descendant
      has_many :ancestors, :through => :ancestors_ancestries, :source => :ancestor, :source_type => clazz.name.to_s
      has_many :descendants_ancestries, :class_name => "Ancestry", :as => :ancestor
      has_many :descendants, :through => :descendants_ancestries, :source => :descendant, :source_type => clazz.name.to_s 
    }
  end
  
  def ancestor
    if ancestors
      return ancestors.first
    end
    return nil
  end
  
  def ancestor=(ancestor)
    ancestors.clear
    if ancestor
      ancestors << ancestor
    end
  end

  # return an array of ancestors, oldest first
  def pedigree
    pedigree_list = []
    a = ancestor
    while a && a != self
        pedigree_list.unshift a
      a = a.ancestor
    end
    pedigree_list
  end
  
  # return everything to which this item is an ancestor
  # kind of the inverse of pedigree
  def all_descendants
    results = []
    results << descendants
    results << descendants.map { |d| d.all_descendants.uniq}
    results.flatten.uniq
  end
  
  

end
