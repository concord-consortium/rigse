require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::InnerPagesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_inner_page
    assert_select('OTCompoundDoc') do
      assert_select('bodyText') do
        assert_select('table') do
          assert_select('tr') do
            assert_select('td') do
              assert_select('div') do
                assert_select('object')
              end
            end
          end
        end
      end
    end
  end

end
