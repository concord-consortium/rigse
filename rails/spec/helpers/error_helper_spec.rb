# frozen_string_literal: false

require 'spec_helper'

class TestClass
  include ActiveModel::Model
  attr_accessor :name, :email
  validates_presence_of :name
  validates_presence_of :email
end

RSpec.describe ErrorHelper, type: :helper do
  # TODO: auto-generated
  describe '#error_messages_for' do
    it 'works' do
      example = TestClass.new
      example.errors.add(:name)
      example.errors.add(:email)
      result = helper.error_messages_for(example)
      expect(result).to  match /2 errors found for Test class/
    end
  end

end
