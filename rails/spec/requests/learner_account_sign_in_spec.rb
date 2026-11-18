require 'spec_helper'

# A teacher learner account cannot sign in with a password, even when the password is right.
RSpec.describe 'Password sign-in for a teacher learner account', type: :request do
  # See learner_account_changes_spec.rb.
  before(:all) { Rails.application.reload_routes_unless_loaded }

  let(:password)     { 'a-known-password-1' }
  let(:teacher)      { FactoryBot.create(:portal_teacher) }
  let(:learner_user) do
    teacher.find_or_create_teacher_learner!.tap do |user|
      user.update!(password: password, password_confirmation: password)
    end
  end
  let(:student_user) do
    FactoryBot.create(:full_portal_student).user.tap do |user|
      user.update!(password: password, password_confirmation: password)
    end
  end

  def signed_in_user_id
    session['warden.user.user.key']&.first&.first
  end

  it 'refuses the learner account on the login form' do
    # A failed login redirects back to the page the form was on.
    post '/users/sign_in', params: { user: { login: learner_user.login, password: password } },
                           headers: { 'HTTP_REFERER' => 'http://www.example.com/' }
    expect(response).to redirect_to('http://www.example.com/')
    expect(signed_in_user_id).to be_nil
  end

  it 'refuses the learner account on the API sign-in' do
    post '/api/v1/users/sign_in', params: { user: { login: learner_user.login, password: password } }, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it 'still lets a normal student sign in on the login form' do
    post '/users/sign_in', params: { user: { login: student_user.login, password: password } }
    expect(signed_in_user_id).to eq(student_user.id)
  end

  it 'still lets a normal student sign in on the API sign-in' do
    post '/api/v1/users/sign_in', params: { user: { login: student_user.login, password: password } }, as: :json
    expect(response).to have_http_status(:ok)
  end

  it 'refuses the learner account in User.authenticate' do
    expect(User.authenticate(learner_user.login, password)).to be_nil
    expect(User.authenticate(student_user.login, password)).to eq(student_user)
  end
end
