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
    return ancestors.first
  end
  
  def ancestor=(ancestor)
    ancestors.clear
    ancestors << ancestor
  end

  # def calculate pedigree
  #   cache_old_pedigree
  #   acestr = ancestor
  #   pedigree=[]
  #   while acestr
  #     pedigree << acestr.name
  #     acestr = acestr.ancestor
  #   end
  # end

end
