FactoryBot.define do
  factory :image_question, :class => Embeddable::ImageQuestion do |f|
    f.prompt "Choose something from your lab book"
  end
end

