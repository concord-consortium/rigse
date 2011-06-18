require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::InnerPagesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_inner_page
    with_tag('OTCompoundDoc') do
      with_tag('bodyText') do
        with_tag('table') do
          with_tag('tr') do
            with_tag('td') do
              with_tag('div') do
                with_tag('object')
              end
            end
          end
        end
      end
    end
  end

end
