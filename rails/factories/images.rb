FactoryBot.define do
  factory :image do
    name { "my secret image" }
    publication_status { "public" }

    association :user, factory: :user

    after(:build) do |image|
      image.image.attach(
        io: File.open(Rails.root.join("spec/fixtures/images/rails.png")),
        filename: "rails.png",
        content_type: "image/png"
      )
    end
  end
end
