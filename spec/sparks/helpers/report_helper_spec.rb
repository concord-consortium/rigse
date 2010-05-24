require 'spec_helper'

class MockView
  include Sparks::ReportHelper
end

describe Sparks::ReportHelper do
  
  before do
    @view = MockView.new
  end

  it 'does time_from_ms correctly' do
    @view.time_from_ms(1274729050984).to_s.should eql('Mon May 24 15:24:10 -0400 2010')
  end

end
