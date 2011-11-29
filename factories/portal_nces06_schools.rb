Factory.sequence(:nces_school_name) { |n| "factory generated nces school ##{n}" }
  
Factory.define :portal_nces06_school, :class => Portal::Nces06School do |f|
  f.GSLO    "07"
  f.GSHI    "12"
  f.PHONE   "8005551212"
  f.MSTREE  "Drury Lane"
  f.MCITY   "Peekskill"
  f.MSTATE  "NY"
  f.MZIP    "00001"
  f.LATCOD   45.00
  f.LONCOD   -80.00
  f.MEMBER   607
  f.FTE      49.0
  f.TOTFRL   265
  f.SCHNAM {Factory.next :nces_school_name}
  f.association :nces_district, :factory => :portal_nces06_district
end

