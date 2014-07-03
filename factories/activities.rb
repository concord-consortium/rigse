Factory.define :activity do |f|
  f.association :user
end

Factory.define :activity_template, parent: :activity do |f|
  f.after_create do |act|
    FactoryGirl.create_list(:external_activity, 2, template: act, url: "http://activity.external.com/1/2/3")
  end
end