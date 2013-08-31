require File.expand_path('../../spec_helper', __FILE__)

describe ExternalActivity do
  let(:valid_attributes) { {
      :user_id => 1,
      :uuid => "value for uuid",
      :name => "value for name",
      :description => "value for description",
      :publication_status => "value for publication_status",
      :is_official => true,
      :url => "http://www.concord.org/"
    } }

  it "should create a new instance given valid attributes" do
    ExternalActivity.create!(valid_attributes)
  end

  describe '#search_list' do
    let (:official) do
      ea = ExternalActivity.create!(valid_attributes)
      ea.publication_status = 'published'
      ea.save
      ea
    end
    let (:contributed) do
      ea = ExternalActivity.create!(valid_attributes)
      ea.is_official = false
      ea.publication_status = 'published'
      ea.save
      ea
    end
    let (:private_activity) do
      ea = ExternalActivity.create!(valid_attributes)
      ea.is_official = false
      ea.publication_status = 'private'
      ea.save
      ea
    end
    let (:official_tagged) do
      Admin::Tag.create!(:scope => 'cohorts', :tag => 'research_group')
      ea = ExternalActivity.create!(valid_attributes)
      ea.publication_status = 'published'
      ea.cohort_list = ["research_group"]
      ea.save
      ea
    end

    context 'when include_community is true' do
      let (:params) { { :include_contributed => true } }
      before(:each) do
        official
        contributed
      end

      it 'should return activities where is_official is true or false' do
        external = ExternalActivity.search_list(params)
        external.should include(official, contributed)
      end
    end

    context 'when include_contributed is false or absent' do
      let (:params) { { } }
      before(:each) do
        official
      end

      it 'should return only activities where is_official is true' do
        external = ExternalActivity.search_list(params)
        external.should include(official)
      end
    end

    context 'when author is searching' do
      it 'should return private activities authored by author' do
        user = mock_model(User, :id => 1, :portal_teacher => false)
        private_activity
        external = ExternalActivity.search_list({:user => user})
        external.should include(private_activity)
      end
      it 'should still appy the name criteria even if activities are authored by author' do
        user = mock_model(User, :id => 1, :portal_teacher => false)
        private_activity
        external = ExternalActivity.search_list({:user => user, :name => 'blah'})
        external.should_not include(private_activity)
      end
    end
    context 'when user has no cohorts' do
      it 'should not return activities tagged with a cohort' do
        teacher = mock_model(Portal::Teacher, :cohort_list => [])
        user = mock_model(User, :id => 2, :portal_teacher => teacher, :has_role? => false)
        official
        official_tagged
        external = ExternalActivity.search_list({:user => user})
        external.should_not include(official_tagged)
        external.should include(official)
      end
    end
  end

  describe "url transforms" do
    let(:activity) { ExternalActivity.create!(valid_attributes)}
    let(:learner) { mock_model(Portal::Learner, :id => 34) }

    it "should default to not appending the learner id to the url" do
      activity.append_learner_id_to_url.should be_false
    end

    it "should return the original url when appending is false" do
      activity.url.should eql(valid_attributes[:url])
      activity.url(learner).should eql(valid_attributes[:url])
    end

    it "should return a modified url when appending is true" do
      activity.append_learner_id_to_url = true
      activity.url.should eql(valid_attributes[:url])
      activity.url(learner).should eql(valid_attributes[:url] + "?learner=34")
    end

    it "should return a correct url when appending to a url with existing params" do
      url = "http://www.concord.org/?foo=bar"
      activity.append_learner_id_to_url = true
      activity.url = url
      activity.url(learner).should eql(url + "&learner=34")
    end

    it "should return a correct url when appending to a url with existing fragment" do
      url = "http://www.concord.org/#3"
      activity.append_learner_id_to_url = true
      activity.url = url
      activity.url(learner).should eql(url + "?learner=34")
    end
  end
end
