FactoryGirl.define do
  factory :external_report do |f|
    f.name 'Some external report'
    f.url 'http://external.report.com'
    f.launch_text 'Custom launch text'
    f.association :client
  end
end
