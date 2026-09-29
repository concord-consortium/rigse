require 'spec_helper'

RSpec.describe TokenCapabilities do
  # A capability whose context type names no record would make authorize refuse every
  # request for it with the same access_denied a researcher without access gets.
  it 'resolves the record for every context type a capability declares' do
    types = TokenCapabilities.context_types(TokenCapabilities.names)
    expect(types).not_to be_empty
    types.each do |type|
      expect(TokenCapabilities::CONTEXT_TYPES).to have_key(type)
      expect(TokenCapabilities::CONTEXT_TYPES[type].constantize).to be < ActiveRecord::Base
    end
  end

  it 'names the same type in both directions' do
    clazz = FactoryBot.create(:portal_clazz)
    expect(TokenCapabilities.context_type_for(clazz)).to eq TokenCapabilities::CLASS_CONTEXT
    expect(TokenCapabilities.context_record(TokenCapabilities::CLASS_CONTEXT, clazz.id)).to eq clazz
  end

  # The authorize request spells a context as "<type>:<id>", so a registered type its parser
  # cannot read would be refused as invalid_request, as a malformed context is.
  it 'registers only context types the authorize parameter can express' do
    expect(TokenCapabilities::CONTEXT_TYPES.keys).not_to be_empty
    TokenCapabilities::CONTEXT_TYPES.each_key do |type|
      expect(AccessGrant.parse_context("#{type}:1")).to eq(type: type, id: 1)
    end
  end

  it 'has neither a record nor a type for anything it does not name' do
    expect(TokenCapabilities.context_record('project', 1)).to be_nil
    expect(TokenCapabilities.context_record(TokenCapabilities::CLASS_CONTEXT, 0)).to be_nil
    expect(TokenCapabilities.context_type_for(User.new)).to be_nil
  end
end
