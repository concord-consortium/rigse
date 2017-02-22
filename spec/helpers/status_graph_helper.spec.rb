require 'spec_helper'

include ApplicationHelper
include Haml::Helpers

describe StatusGraphHelper do
  before :each do
    init_haml_helpers
  end
  let(:percent)  { 0 }
  let(:activity) { false}
  let(:classes)  { nil }
  subject { helper.bar_graph(percent,activity,classes)}
  describe ".bar_graph" do
    context "almost complete" do
      let(:percent) { 99.99 } #as in external activities
      it { is_expected.to match(/progress/)    }
      it { is_expected.not_to match(/complete/) }
    end
    context "complete" do
      let(:percent) { 99.993 }
      it { is_expected.to match(/progress/) }
      it { is_expected.to match(/complete/) }
      it { is_expected.not_to match(/activity/) }
    end
    context "activity" do
      let(:activity) { true }
      it { is_expected.to match(/progress/)    }
      it { is_expected.not_to match(/complete/) }
      it { is_expected.to match(/activity/) }
    end
  end
end

