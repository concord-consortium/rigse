require File.expand_path('../../../spec_helper', __FILE__)

describe Embeddable::MultipleChoicesController do

  it_should_behave_like 'an embeddable controller'

  def with_tags_like_an_otml_multiple_choice
    assert_select('OTQuestion') do
      assert_select('prompt') do
        assert_select('OTCompoundDoc') do
          assert_select('bodyText')
        end
      end
      assert_select('input') do
        assert_select('OTChoice') do
          assert_select('choices')
        end
      end
    end
  end

  # TODO: auto-generated
  describe '#add_choice' do
    it 'GET add_choice' do
      get :add_choice, id: FactoryGirl.create(:multiple_choice).to_param

      expect(response).to have_http_status(:not_acceptable)
    end
  end


end
