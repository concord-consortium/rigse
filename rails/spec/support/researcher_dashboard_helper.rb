# Enables the dashboard for an example (enabled? reads ENV per call) and restores ENV afterwards.
module ResearcherDashboardHelper
  ENVIRONMENT = {
    'RESEARCHER_DASHBOARD_URL' => 'https://researcher-dashboard.example/'
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
