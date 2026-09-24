module ResearcherDashboard
  # One call to report-server or the report-service function. Every call has its own open
  # and read timeouts, and a timeout or a connection failure becomes a Refusal rather than
  # an exception reaching Rails as a 500. Nothing here logs a request or response body,
  # because the run path's bodies carry runner tokens.
  module Upstream
    OPEN_TIMEOUT = 5
    REASON_MAX = 300
    NAMES = { report_server: 'report-server', function: 'report-service' }.freeze

    def self.get(upstream, url, query:, bearer:, read_timeout:)
      call(upstream) do
        HTTParty.get(url, query: query, headers: { 'Authorization' => "Bearer #{bearer}", 'Accept' => 'application/json' },
                     open_timeout: OPEN_TIMEOUT, read_timeout: read_timeout)
      end
    end

    def self.post_json(upstream, url, body:, bearer:, read_timeout:)
      call(upstream) do
        HTTParty.post(url, body: JSON.generate(body),
                      headers: { 'Authorization' => "Bearer #{bearer}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' },
                      open_timeout: OPEN_TIMEOUT, read_timeout: read_timeout)
      end
    end

    # The upstream's own words for a refusal: runnable:false's reason, report-server's
    # message (its envelope is {error: CODE, message}), the function's `error`, or a
    # plain-text body. Truncated, and never the request's own body.
    def self.reason(response)
      body = begin
        response.parsed_response
      rescue StandardError
        response.body
      end
      text = body.is_a?(Hash) ? (body['reason'] || body['message'] || body['error']) : body
      text.to_s.strip.truncate(REASON_MAX)
    end

    def self.refusal(upstream, response, status: 502, message: nil)
      reason = reason(response)
      name = NAMES.fetch(upstream)
      message ||= "#{name} answered #{response.code}"
      message = "#{message}: #{reason}" if reason.present?
      log(name, response.code, reason)
      Refusal.new(status, message, { upstream: name, status: response.code, reason: reason })
    end

    # One grep-able warning per upstream failure; never a body, so never a token.
    def self.log(name, status, reason)
      Rails.logger.warn("researcher_dashboard.upstream_refusal upstream=#{name} status=#{status.inspect} reason=#{reason.inspect}")
    end

    # Net::HTTP's failures share no ancestor narrower than StandardError, so each family is listed.
    CONNECTION_ERRORS = [SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError,
                         Net::HTTPBadResponse, Net::ProtocolError, HTTParty::Error].freeze

    def self.call(upstream)
      yield
    rescue Timeout::Error => e
      name = NAMES.fetch(upstream)
      log(name, nil, e.class.name)
      raise Refusal.new(504, "#{name} did not answer in time", { upstream: name, status: nil, reason: e.class.name })
    rescue *CONNECTION_ERRORS => e
      name = NAMES.fetch(upstream)
      log(name, nil, e.class.name)
      raise Refusal.new(502, "#{name} could not be reached", { upstream: name, status: nil, reason: e.class.name })
    end
    private_class_method :call, :log
  end
end
