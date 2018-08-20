# frozen_string_literal: false

require 'spec_helper'

RSpec.describe API::V1::AnswersController, type: :controller do

  # TODO: auto-generated
  describe '#student_answers' do
    it 'GET student_answers' do
      get :student_answers, {}, {}

      expect(response).to have_http_status(:forbidden)
    end
  end

end
