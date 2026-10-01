require 'spec_helper'

RSpec.describe 'Researcher Dashboard API CORS', type: :request do
  it 'allows a preflight from another origin with a bearer' do
    process :options, '/api/v1/researcher_dashboard/run_package', headers: {
      'Origin' => 'https://researcher-dashboard.example',
      'Access-Control-Request-Method' => 'POST',
      'Access-Control-Request-Headers' => 'authorization,content-type'
    }
    expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    expect(response.headers['Access-Control-Allow-Methods']).to match(/POST/)
    expect(response.headers['Access-Control-Allow-Headers']).to match(/authorization/i)
    expect(response.headers['Access-Control-Allow-Headers']).to match(/content-type/i)
  end
end
