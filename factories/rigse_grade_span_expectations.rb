Factory.define :rigse_grade_span_expectation, :class => RiGse::GradeSpanExpectation do |f|
    f.association :assessment_target, :factory => :rigse_assessment_target
end

