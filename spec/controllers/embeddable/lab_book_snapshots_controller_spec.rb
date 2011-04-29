require 'spec_helper'

describe Embeddable::LabBookSnapshotsController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_lab_book_snapshot
    with_tag('OTLabbookButton') do
      with_tag('target')
    end
  end

end
