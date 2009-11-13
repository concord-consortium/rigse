Factory.define :investigation do |f|
    f.name "tests investigation"
    f.description "fake investigation description"
    f.association :user, :factory => :user
end

