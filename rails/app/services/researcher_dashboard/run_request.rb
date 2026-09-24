module ResearcherDashboard
  # The run request's body, which is exactly {"packages": [{"identity", "version"}]}. The
  # scope is in the launch token and the checksum comes from the catalog, so any other key,
  # a checksum or package key above all, is refused rather than ignored.
  module RunRequest
    # The function's default queue cap; a larger batch could never be queued whole.
    MAX_PACKAGES = 20
    # The catalog's identity and version grammar. \A and \z, not ^ and $, which match at a newline.
    IDENTITY = %r{\A(users|projects)/[0-9]+/[a-z0-9][a-z0-9-]{0,62}\z}
    VERSION = /\A[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?\z/

    def self.parse(raw)
      body = begin
        JSON.parse(raw.to_s)
      rescue JSON::ParserError
        invalid('The body must be a JSON object')
      end
      invalid('The body must be a JSON object') unless body.is_a?(Hash)
      extra = body.keys - ['packages']
      invalid("Unexpected keys in the body: #{extra.join(', ')}") if extra.any?
      packages = body['packages']
      unless packages.is_a?(Array) && packages.size.between?(1, MAX_PACKAGES)
        invalid("packages must be a list of 1 to #{MAX_PACKAGES} packages")
      end

      parsed = packages.each_with_index.map do |entry, i|
        invalid("packages[#{i}] must be an object") unless entry.is_a?(Hash)
        extra = entry.keys - %w[identity version]
        invalid("packages[#{i}] has unexpected keys: #{extra.join(', ')}") if extra.any?
        identity, version = entry['identity'], entry['version']
        invalid("packages[#{i}].identity is not a package identity") unless identity.is_a?(String) && IDENTITY.match?(identity)
        invalid("packages[#{i}].version is not a package version") unless version.is_a?(String) && VERSION.match?(version)
        { identity: identity, version: version }
      end
      # One result document per identity per class, so one batch cannot hold two versions.
      duplicate = parsed.group_by { |p| p[:identity] }.find { |_, v| v.size > 1 }&.first
      invalid("#{duplicate} appears more than once") if duplicate
      parsed
    end

    def self.invalid(message)
      raise Refusal.new(400, message)
    end
    private_class_method :invalid
  end
end
