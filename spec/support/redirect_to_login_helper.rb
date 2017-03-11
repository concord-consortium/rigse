RSpec::Matchers.define :redirect_to_path do |path|
  match do |response|
    return false if response.status != 302
    URI.parse(response.location).path == path
  end
end
