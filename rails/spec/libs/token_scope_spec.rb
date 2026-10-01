require 'spec_helper'

RSpec.describe TokenScope do
  after(:each) { Current.reset }
  let(:clazz) { FactoryBot.create(:portal_clazz) }
  let(:other) { FactoryBot.create(:portal_clazz) }

  it 'leaves an unscoped token unscoped, and allows it everything' do
    TokenScope.apply!('uid' => 1)
    expect(TokenScope.scoped?).to be false
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)).to be true
  end

  it 'allows a context-bound capability only on the token context' do
    TokenScope.apply!('scope' => 'class:researcher-read', 'context' => { 'type' => 'class', 'id' => clazz.id })
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)).to be true
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, other)).to be false
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_RUN, clazz)).to be false
  end

  it 'fails every context-bound check for a scoped token without a context' do
    TokenScope.apply!('scope' => 'class:researcher-read')
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)).to be false
    TokenScope.apply!('scope' => 'class:researcher-read', 'context' => { 'type' => 'class', 'id' => clazz.id.to_s })
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)).to be false
  end

  # Capabilities are flat, so run does not imply read or the reverse.
  it 'never lets one capability stand in for another' do
    TokenScope.apply!('scope' => 'class:researcher-run', 'context' => { 'type' => 'class', 'id' => clazz.id })
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_RUN, clazz)).to be true
    expect(TokenScope.allows?(TokenCapabilities::CLASS_RESEARCHER_READ, clazz)).to be false
  end

  it 'refuses everything to an empty scope' do
    TokenScope.apply!('scope' => '')
    expect(TokenScope.scoped?).to be true
    expect(TokenScope.allows?(TokenCapabilities::PORTAL_API)).to be false
  end
end
