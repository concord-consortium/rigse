Factory.define :activity do |f|
  f.description "sample activity from factory"
  f.sequence(:name) {|n| "sample activity from factory (#{n})" }
  f.association :user
end

