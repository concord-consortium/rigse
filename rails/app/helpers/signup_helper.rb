
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

end