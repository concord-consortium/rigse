shared_examples 'projects listing' do
  let (:project_name) { 'project foo bar test' }
  let (:project_slug) { 'project-foo-bar-test' }
  before(:each) do
    FactoryBot.create(:project, name: project_name, landing_page_slug: project_slug)
  end

  context 'when user is an admin' do
    before(:each) do
      allow(view).to receive(:current_visitor).and_return(FactoryBot.generate(:admin_user))
      allow(view).to receive(:current_user).and_return(FactoryBot.generate(:admin_user))
    end
    it 'should be visible' do
      render
      expect(rendered).to have_content(project_name)
    end
  end

  context 'when user is an author' do
    before(:each) do
      allow(view).to receive(:current_visitor).and_return(FactoryBot.generate(:author_user))
      allow(view).to receive(:current_user).and_return(FactoryBot.generate(:author_user))
    end
    it 'should not be visible' do
      render
      expect(rendered).not_to have_content(project_name)
    end
  end
end
