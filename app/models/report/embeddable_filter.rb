class Report::EmbeddableFilter < ActiveRecord::Base
  set_table_name "report_embeddable_filters"
  
  belongs_to :offering, :class_name => "Portal::Offering", :foreign_key => "offering_id"
  
  serialize :embeddables
  
  validates_uniqueness_of :offering_id
  
  def filter(collection)
    embs = embeddables
    if embs.size == 0
      return collection
    end
    return collection & embeddables
  end
  
  def embeddables
    @embeddables_internal = read_attribute(:embeddables).map{|em| em[:type].constantize.find(em[:id]) }.compact.uniq unless @embeddables_internal
    return @embeddables_internal
  end
  
  def embeddables=(array)
    items = array.map{|em| {:type => em.class.to_s, :id => em.id } }
    write_attribute(:embeddables, items)
    @embeddables_internal = array
  end
  
  def reload
    @embeddables_internal = nil
    super
  end
end
