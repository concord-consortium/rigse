FactoryGirl.define do
  factory :materials_collection_item do
    sequence(:position)
    association :material, factory: :investigation
    association :materials_collection
  end

  factory :materials_collection do
    name        "Some name"
    description "Some description"
    # association :project, :factory => :admin_project

    factory :materials_collection_with_items do
      ignore do
        items_count 5
      end

      after(:create) do |collection, evaluator|
        create_list(:materials_collection_item, evaluator.items_count, materials_collection: collection)
      end
    end
  end
end
