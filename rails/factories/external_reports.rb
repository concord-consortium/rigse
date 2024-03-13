FactoryBot.define do
  factory :external_report do |f|
    f.name {'Some external report'}
    f.url {'http://external.report.com'}
    f.launch_text {'Custom launch text'}
    f.report_type {'offering'}
    f.association :client
  end
end

FactoryBot.define do
  factory :default_lara_report, parent: :external_report do |f|
    f.name {'Report'}
    f.url {'http://fake-report.concord.org'}
    f.launch_text {'Report'}
    f.report_type {"offering"}
    f.allowed_for_students {true}
    f.default_report_for_source_type {"LARA"}
    f.individual_student_reportable {true}
    f.individual_activity_reportable {true}
    f.use_query_jwt {false}
    f.supports_researchers {false}
  end
end
