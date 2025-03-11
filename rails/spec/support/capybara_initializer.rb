class CapybaraInitializer
  attr_accessor :headless, :context
  alias :headless? :headless

  def initialize
    @headless = true
  end

  def call
    configure_capybara_defaults
    register_selenium_driver
    register_headless_chrome_driver

    Capybara.javascript_driver = :selenium
  end

  def self.configure
    initializer = new
    yield initializer if block_given?
    initializer.call
  end

  private

  def configure_capybara_defaults
    # Capybara defaults to XPath selectors rather than Webrat's default of CSS3. In
    # order to ease the transition to Capybara we set the default here. If you'd
    # prefer to use XPath just remove this line and adjust any selectors in your
    # steps to use the XPath syntax.
    Capybara.default_selector = :css
    # Increase default wait time for asynchronous JavaScript requests from 2 to 5s
    # see section on Asynchronous JavaScript here: https://github.com/jnicklas/capybara
    Capybara.default_max_wait_time = 5
    Capybara.server = :webrick

    # Add some Capybara config if we are running
    # Chrome on the docker host machine.
    if !headless? && docker?
      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = '43447'
    end
  end

  def register_selenium_driver
    Capybara.register_driver(:selenium) do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: selenium_options)
    end
  end

  def register_headless_chrome_driver
    Capybara.register_driver(:headless_chrome) do |app|
      Capybara::Selenium::Driver.new(app, browser: :chrome, options: headless_chrome_options)
    end
  end

  def selenium_options
    options = Selenium::WebDriver::Options.chrome
    options.binary = "/usr/bin/chromium"

    unique_user_data_dir = "/dev/shm/chrome-profile-#{Process.pid}"
    FileUtils.mkdir_p(unique_user_data_dir)
    FileUtils.chmod(0o777, unique_user_data_dir)

    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--user-data-dir=#{unique_user_data_dir}")
    options.add_argument("--disable-gpu")
    options.add_argument("--window-size=1440,900")
    options.add_argument('--disable-features=PermissionsPolicy')

    options.add_argument("--headless=new") if headless
    options
  end

  def headless_chrome_options
    options = Selenium::WebDriver::Chrome::Options.new
    options.binary = "/usr/bin/chromium"

    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--window-size=1440,900')

    options
  end

  def docker?
    context == :docker
  end
end
