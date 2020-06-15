class SecurityQuestionsController < ApplicationController

  protected

  def not_authorized_error_message
    super({resource_type: 'security question'})
  end

  public

  # GET
  def edit
    authorize SecurityQuestion
    @security_questions = SecurityQuestion.fill_array(current_visitor.security_questions)
  end

  # PUT
  def update
    authorize SecurityQuestion
    @security_questions = SecurityQuestion.make_questions_from_hash_and_user(params[:security_questions], current_visitor)
    errors = SecurityQuestion.errors_for_questions_list!(@security_questions)
    if (!errors) || errors.empty?
      current_visitor.update_security_questions!(@security_questions)
      flash[:notice] = "Your security questions have been successfully updated."
      redirect_to(root_path)
    else
      flash[:error] = errors.join(", ")
      @security_questions = SecurityQuestion.fill_array(@security_questions)
      render :action => "edit"
    end
  end

  protected

  # def make_questions_from_params
  #   (0..2).to_a.collect do |i|
  #     data = params["question#{i}"]
  #     next if data.nil?
  #
  #     existing_object = current_visitor.security_questions.find_by_id(data[:id]) if data[:id] && data[:question_idx] == "current"
  #
  #     if existing_object.nil?
  #       new_question = SecurityQuestion::QUESTIONS[data[:question_idx].to_i] if data[:question_idx].to_i.to_s == data[:question_idx].to_s
  #       next if new_question.nil?
  #     else
  #       new_question = existing_object.question
  #     end
  #
  #     SecurityQuestion.new({ :question => new_question, :answer => data[:answer] })
  #   end.compact
  # end
end
