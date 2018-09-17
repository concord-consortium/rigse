FactoryGirl.define do
  factory :portal_nces06_school, :class => Portal::Nces06School do
    GSHI "12"
    PHONE "8005551212"
    MSTREE "Drury Lane"
    MCITY "Peekskill"
    MSTATE "NY"
    MZIP "00001"
    LATCOD 45.00
    LONCOD -80.00
    MEMBER 607
    FTE 49.0
    TOTFRL 265
    sequence(:SCHNAM) {|n| "factory generated nces school ##{n}"}
    association :nces_district, :factory => :portal_nces06_district
  end
end

