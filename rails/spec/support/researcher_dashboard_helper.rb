# The settings the refresh and run paths read per call, set for an example and restored afterwards.
module ResearcherDashboardHelper
  ENVIRONMENT = {
    'REPORT_SERVER_URL' => 'https://report-server.example/',
    'RESEARCHER_DASHBOARD_FUNCTION_URL' => 'https://functions.example/researcherDashboard',
    'RESEARCHER_DASHBOARD_FIREBASE_APP' => 'report-service-dev',
    'RESEARCHER_DASHBOARD_CLUE_FIREBASE_APP' => 'collaborative-learning-staging'
  }.freeze

  RSpec.shared_context 'with the researcher dashboard configured' do
    around(:each) do |example|
      previous = ENVIRONMENT.keys.index_with { |name| ENV[name] }
      ENV.update(ENVIRONMENT)
      begin
        example.run
      ensure
        previous.each { |name, value| ENV[name] = value }
      end
    end
  end
end
