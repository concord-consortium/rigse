class CapybaraInitializer

  attr_accessor :headless, :context
  alias :headless? :headless

  def initialize
    @headless = true
  end

  def call
    # Common Capybara configuration
    Capybara.default_max_wait_time = 5

    # Add some Capybara config if we are running
    # Chrome on the docker host machine.
    if !headless? && docker?
      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = '43447'
    end

    # Register the driver
    Capybara.register_driver(:selenium) { |app| driver(app) }
    Capybara.javascript_driver = :selenium
  end

  def self.configure
    initializer = new
    yield initializer if block_given?
    initializer.call
  end

  private

  def driver(app)
    Capybara::Selenium::Driver.new(app, driver_options)
  end

  def driver_options
    { browser: :chrome, desired_capabilities: capabilities }.tap do |a|
      a[:url] = 'http://host.docker.internal:9515/' if !headless? && docker?
    end
  end

  def capabilities
    Selenium::WebDriver::Remote::Capabilities.chrome(
      'chromeOptions' => {
        'args' => chrome_options
      }
    )
  end

  def chrome_options
    %w(no-sandbox disable-gpu window-size=1440,900).tap do |a|
      a << 'headless' if headless?
    end
  end

  def docker?
    context == :docker
  end
end