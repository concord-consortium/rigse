class Rack::ResponseLogger

  def initialize(app)
    @app = app
  end

  def call(env)
    queue_time = measure_queue_time(env)
    if queue_time.present?
      Rails.logger.info "QueueTime #{queue_time} \"#{env['PATH_INFO']}\""
    end

    @app.call(env)
  end

  private

  # this code was taken from the prometheus_exporter project:
  # https://github.com/discourse/prometheus_exporter/blob/900a9f22e4724e68b1d83c7f2eacbbb143594f1e/lib/prometheus_exporter/middleware.rb#L57-L89
  # it is licensed with an MIT license

  # measures the queue time (= time between receiving the request in downstream
  # load balancer and starting request in ruby process)
  def measure_queue_time(env)
    start_time = queue_start(env)

    return unless start_time

    queue_time = request_start.to_f - start_time.to_f
    queue_time unless (queue_time < 0)
  end

  # need to use CLOCK_REALTIME, as nginx/apache write this also out as the unix timestamp
  def request_start
    Process.clock_gettime(Process::CLOCK_REALTIME)
  end

  # get the content of the x-queue-start or x-request-start header
  def queue_start(env)
    value = env['HTTP_X_REQUEST_START'] || env['HTTP_X_QUEUE_START']
    unless value.nil? || value == ''
      convert_header_to_ms(value.to_s)
    end
  end

  # nginx returns time as milliseconds with 3 decimal places
  # apache returns time as microseconds without decimal places
  # this method takes care to convert both into a proper second + fractions timestamp
  def convert_header_to_ms(str)
    str = str.gsub(/t=|\./, '')
    "#{str[0,10]}.#{str[10,13]}".to_f
  end

end
