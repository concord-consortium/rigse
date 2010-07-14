Factory.define :rigse_grade_span_expectation, :class => RiGse::GradeSpanExpectation do |f|
    begin
      f.grade_span RiGse::GradeSpanExpectation.default
    rescue
    end
    f.association :assessment_target, :factory => :rigse_assessment_target
end

