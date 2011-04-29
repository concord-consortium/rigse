Factory.define :page_element do |f|
  f.association   :embeddable, :factory => :xhtml
end

