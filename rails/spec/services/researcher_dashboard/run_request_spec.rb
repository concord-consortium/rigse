require 'spec_helper'

RSpec.describe ResearcherDashboard::RunRequest do
  def package(identity = 'projects/20/class-counts', version = '1.0.0')
    { 'identity' => identity, 'version' => version }
  end

  def parse(body)
    described_class.parse(body.is_a?(String) ? body : JSON.generate(body))
  end

  def refusal(body)
    parse(body)
    raise 'expected a Refusal'
  rescue ResearcherDashboard::Refusal => e
    expect(e.status).to eq(400)
    e.message
  end

  it 'accepts one package' do
    expect(parse('packages' => [package])).to eq([{ identity: 'projects/20/class-counts', version: '1.0.0' }])
  end

  it 'accepts twenty packages in order' do
    packages = (1..20).map { |i| package("users/7/p#{i}") }
    expect(parse('packages' => packages).map { |p| p[:identity] }).to eq((1..20).map { |i| "users/7/p#{i}" })
  end

  it 'accepts a prerelease version' do
    expect(parse('packages' => [package('users/7/p', '2.10.3-rc.1')]).first[:version]).to eq('2.10.3-rc.1')
  end

  it 'refuses malformed JSON' do
    expect(refusal('{"packages": [')).to eq('The body must be a JSON object')
  end

  it 'refuses a body that is not an object' do
    expect(refusal([package])).to eq('The body must be a JSON object')
  end

  it 'refuses an extra top-level key' do
    expect(refusal('packages' => [package], 'class_id' => 1)).to eq('Unexpected keys in the body: class_id')
  end

  it 'refuses an empty list, a missing list and 21 packages' do
    expect(refusal('packages' => [])).to match(/1 to 20 packages/)
    expect(refusal({})).to match(/1 to 20 packages/)
    expect(refusal('packages' => (1..21).map { |i| package("users/7/p#{i}") })).to match(/1 to 20 packages/)
  end

  it 'refuses an entry that is not an object' do
    expect(refusal('packages' => ['projects/20/a'])).to eq('packages[0] must be an object')
  end

  %w[checksum package_key catalog_id].each do |key|
    it "refuses an entry carrying #{key}" do
      expect(refusal('packages' => [package.merge(key => 'x')])).to eq("packages[0] has unexpected keys: #{key}")
    end
  end

  ['projects/20/class_counts', "projects/20/class-counts\n", 'class-counts', 'teams/20/a', 'projects/20/-a', 7].each do |identity|
    it "refuses the identity #{identity.inspect}" do
      expect(refusal('packages' => [package(identity)])).to eq('packages[0].identity is not a package identity')
    end
  end

  ['1.0', 'v1.0.0', "1.0.0\n", '1.0.0-', 1].each do |version|
    it "refuses the version #{version.inspect}" do
      expect(refusal('packages' => [package('users/7/p', version)])).to eq('packages[0].version is not a package version')
    end
  end

  it 'refuses a repeated identity' do
    expect(refusal('packages' => [package, package('projects/20/class-counts', '2.0.0')]))
      .to eq('projects/20/class-counts appears more than once')
  end
end
