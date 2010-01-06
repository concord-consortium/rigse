Factory.define :portal_offering, :class => Portal::Offering do |f|
  f.association :runnable, :factory => :investigation
  f.association :clazz, :factory => :portal_clazz
end

