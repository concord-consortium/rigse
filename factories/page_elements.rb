FactoryGirl.define do
  factory :page_element do |f|
    f.association :embeddable, :factory => :open_response
  end
end

