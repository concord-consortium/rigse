require 'capybara/selenium/driver'

# Capybara's ChromeDriver#reset! passes origin "*" to Storage.clearDataForOrigin, which Chrome 158+
# rejects (https://github.com/teamcapybara/capybara/issues/2865); clear cookies and visited origins here.
module CapybaraChromeResetWithoutWildcardOrigin
  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == 'Storage.clearDataForOrigin' && params[:origin] == '*'

    super('Network.clearBrowserCookies')
    return unless params[:storageTypes].split(',').include?('local_storage')

    history = super('Page.getNavigationHistory')
    origins = history['entries'].filter_map { |entry| http_origin(entry['url']) }.uniq
    origins.each { |origin| super(cmd, origin: origin, storageTypes: 'local_storage') }
  end

  def http_origin(url)
    uri = URI.parse(url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}" if %w[http https].include?(uri.scheme) && uri.host
  rescue URI::InvalidURIError
    nil
  end
end

patched_version = Gem::Version.new('3.40.0')
bundled_version = Gem.loaded_specs['capybara'].version
unless bundled_version == patched_version
  raise "#{__FILE__} patches Capybara #{patched_version} but the bundle has #{bundled_version}. Delete it if " \
        'that release fixes teamcapybara/capybara#2865, otherwise check the patch still fits and update the version.'
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeResetWithoutWildcardOrigin)
