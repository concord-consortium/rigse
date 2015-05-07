shared_examples 'projects listing' do
  let (:project_name) { 'project foo bar test' }
  before(:each) do
    FactoryGirl.create(:project, name: project_name)
  end

  context 'when user is an admin' do
    before(:each) do
      view.stub!(:current_visitor).and_return(Factory.next(:admin_user))
      view.stub!(:current_user).and_return(Factory.next(:admin_user))
    end
    it 'should be visible' do
      render
      expect(rendered).to have_content(project_name)
    end
  end

  context 'when user is an author' do
    before(:each) do
      view.stub!(:current_visitor).and_return(Factory.next(:author_user))
      view.stub!(:current_user).and_return(Factory.next(:author_user))
    end
    it 'should not be visible' do
      render
      expect(rendered).not_to have_content(project_name)
    end
  end
end
