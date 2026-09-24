module ResearcherDashboard
  # The run path's one read of report-server's catalog. It presents the app's own launch
  # token, so report-server applies its visibility rule to this researcher, and it is the
  # only place a checksum or catalog id comes from.
  module Catalog
    # report-server reads the caller's grants from the portal with a five-second timeout.
    READ_TIMEOUT = 10
    CHECKSUM = /\Asha256:[0-9a-f]{64}\z/

    def self.resolve(identity:, version:, launch_token:)
      response = Upstream.get(:report_server, "#{Settings.report_server_url}/api/v1/packages/resolve",
                              query: { identity: identity, version: version }, bearer: launch_token,
                              read_timeout: READ_TIMEOUT)
      label = "#{identity}@#{version}"
      case response.code
      when 200
        body = Upstream.parsed(response)
        unless body.is_a?(Hash) && body['identity'] == identity && body['version'] == version &&
               CHECKSUM.match?(body['checksum'].to_s) && body['catalog_id'].is_a?(Integer) && body['catalog_id'] > 0 &&
               [true, false].include?(body['runnable'])
          raise Upstream.malformed(:report_server, 200, 'malformed resolve answer',
                                   "report-server's answer for #{label} is not a resolved package")
        end
        unless body['runnable']
          raise Upstream.refusal(:report_server, response, status: 409, message: "#{label} cannot be run")
        end
        # Absent on a report-server that predates the field: no CLUE token rather than a failed run.
        { identity: identity, version: version, checksum: body['checksum'], catalog_id: body['catalog_id'],
          clue_prepull: body['clue_prepull'] == true }
      when 404
        raise Upstream.refusal(:report_server, response, status: 409,
                               message: "#{label} cannot be resolved: it does not exist or you may not see it")
      else
        raise Upstream.refusal(:report_server, response, message: "report-server could not resolve #{label}")
      end
    end
  end
end
