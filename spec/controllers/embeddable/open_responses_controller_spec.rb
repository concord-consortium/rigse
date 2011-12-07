require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::OpenResponsesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_open_response
    with_tag('OTText') do
      with_tag('text')
    end
  end

end
