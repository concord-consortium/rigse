
module SignupHelper

  # TODO:  This is basically a placeholder.
  # It isn't working correctly. Hopefully we can fix it later.
  def security_question(number)
    result = <<-EOF
    <div class = 'f-row'>
      <ui-select ng-model="regCtrl.questions[#{number}]"
        name="questions[#{number}]"  theme="select2"
        ui-validate="{unique_question: 'regCtrl.uniqueQuestions($value)'}"
        ng-required non-blank>

        <ui-select-match placeholder="Choose a security question ...">
          {{$select.selected}}
        </ui-select-match>
        <ui-select-choices repeat ="question in regCtrl.security_questions">
          {{question}}
        </ui-select-choices>
        <div ng-messages="signup['questions[#{number}]'].$error">
          <div ng-message="unique_question" class= "error-message">
            You must select 3 different questions
          </div>

        <div class= "f-row">
          <input type ="text"  placeholder = 'Answer (case sensitive)'
            name      = 'answers[#{number}]'
            non-blank server-errors
            ng-model = "regCtrl.answers[#{number}]">

          <div ng-messages = "signup['answers[0]'].$error">
            <div ng-message = "serverError" class= "error-message">
              You must provide an answer
            </div>
          </div>
        </div>
    EOF
    result.gsub(/^\s+/,'').html_safe
  end

  def find_grade_level(params)
    grade_level = Portal::GradeLevel.find_by_name('9')
    if @portal_clazz
      # Try to get a grade level from the class first.
      if (!(grade_levels = @portal_clazz.grade_levels).nil? && grade_levels.size > 0)
        grade_level = grade_levels[0] if grade_levels[0]
      elsif (@portal_clazz.course && @portal_clazz.course.grade_levels && @portal_clazz.course.grade_levels.size > 0)
        course = @portal_clazz.course
        grade_levels = course.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      elsif @portal_clazz.teacher
        grade_levels = @portal_clazz.teacher.grade_levels
        grade_level = grade_levels[0] if grade_levels[0]
      end
    end
    grade_level
  end

end
