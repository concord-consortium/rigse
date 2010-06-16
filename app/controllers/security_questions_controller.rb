class SecurityQuestionsController < ApplicationController
  before_filter :user_has_security_questions
  
  ERROR_BLANK_ANSWER        = "Answers can't be blank."
  ERROR_TOO_FEW_QUESTIONS   = "You must select three questions."
  ERROR_DUPLICATE_QUESTIONS = "You can't use the same question twice."
  
  # GET
  def edit
    @security_questions  = current_user.security_questions
    @security_questions += Array.new(3 - @security_questions.size) { |e| SecurityQuestion.new } if @security_questions.size < 3
  end

  # PUT
  def update
    @security_questions = make_questions_from_params
    
    setQuestions = true
    msg = "There were problems setting your security questions:"
    errors = ""
    
    @security_questions.each do |q|
      if q.answer.empty?
        errors = "<li>#{ERROR_BLANK_ANSWER}</li>"
        q.errors.add :answer, "can't be blank"
        setQuestions = false
      end
    end
        
    if @security_questions.size < 3
      errors += "<li>#{ERROR_TOO_FEW_QUESTIONS}</li>"
      setQuestions = false
    end
        
    if @security_questions.collect { |q| q.question }.uniq.size < @security_questions.size
      errors += "<li>#{ERROR_DUPLICATE_QUESTIONS}</li>"
      setQuestions = false
    end 
        
    if setQuestions
      current_user.security_questions.destroy_all
      
      @security_questions.each do |q|
        current_user.security_questions << q
        q.save
      end

      redirect_to(root_path)
      return
    end
    
    flash[:error] = msg + "<ul>" + errors + "</ul>"
    @security_questions += Array.new(3 - @security_questions.size) { |e| SecurityQuestion.new } if @security_questions.size < 3
    render :action => "edit"
  end
  
  protected
  
  def user_has_security_questions
    unless current_user && !current_user.portal_student.nil?
      redirect_to(root_path)
      return
    end
  end
  
  def make_questions_from_params
    (0..2).to_a.collect do |i|
      data = params["question#{i}"]
      next if data.nil?
      
      existing_object = current_user.security_questions.find_by_id(data[:id]) if data[:id] && data[:question_idx] == "current"
      
      if existing_object.nil?
        new_question = SecurityQuestion::QUESTIONS[data[:question_idx].to_i] if data[:question_idx].to_i.to_s == data[:question_idx].to_s
        next if new_question.nil?
      else
        new_question = existing_object.question
      end
      
      SecurityQuestion.new({ :question => new_question, :answer => data[:answer] })
    end.compact
  end
end
