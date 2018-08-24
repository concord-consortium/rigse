# frozen_string_literal: false

require 'spec_helper'


RSpec.describe Dataservice::PeriodicBundleContentObserver, type: :model do

  # TODO: auto-generated
  describe '#after_create' do
    xit 'after_create' do
      periodic_bundle_content_observer = Dataservice::PeriodicBundleContent.new
      bundle_content = double('bundle_content')
      result = periodic_bundle_content_observer.after_create(bundle_content)

      expect(result).not_to be_nil
    end
  end

end
