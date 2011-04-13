require 'spec_helper'

describe Embeddable::WebModelsController do

  before(:all) do
    wm = Factory.create(:web_model)
    wm.name = "Test web model"
    wm.description = "Test"
    wm.url = "http://www.concord.org/"
    wm.image_url = "http://www.concord.org/sites/all/themes/cc/img/css/bg-sprite-btns.png"
    wm.save
  end

  it_should_behave_like 'an embeddable controller'

  def create_new_web_model
    return Factory.create(:embeddable_web_model)
  end

  def with_tags_like_an_otml_web_model
    with_tag('OTCompoundDoc') do
      with_tag('bodyText')
    end
  end

end
