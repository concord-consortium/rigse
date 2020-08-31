Given("a project called {string}") do |name|
  FactoryBot.create(:project, name: name)
end
