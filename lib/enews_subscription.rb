module EnewsSubscription

  Enews_api_key = ENV['MAILCHIMP_API_KEY']
  Enews_list_id = ENV['MAILCHIMP_API_LISTID']
  Enews_uri = ENV['MAILCHIMP_API_URI']
  Enews_mimetype = {'Content-Type'=>'application/json'}

  def self.build_uri(email)
    digest = Digest::MD5.hexdigest(email)
    URI("#{Enews_uri}/#{Enews_list_id}/members/#{digest}")
  end

  def self.post_request(email, enews_data, req_type)
    uri = build_uri(email)
    if req_type == :put
      req = Net::HTTP::Put.new(uri.path, Enews_mimetype)
    elsif req_type == :get
      req = Net::HTTP::Get.new(uri.path, Enews_mimetype)
    else
      # This is to protect from future coding error where the request type is
      # not what we expect. This exception should never occur in production.
      raise StandardError, "Unexpected request type (:#{req_type.to_s}). Must be :put or :get."
    end
    req.basic_auth("user", Enews_api_key)
    req.body = enews_data.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(req)
  end

  def self.get_status(email)
    enews_data = {
      'email_address' => email
      }
    JSON.parse(post_request(email, enews_data, :get).body)
  end

  def self.set_status(email, status, first_name, last_name)
    enews_data = {
      'email_address' => email,
      'status' => status,
      'merge_fields' => {
        'FNAME' => first_name,
        'LNAME' => last_name
        }
      }
    JSON.parse(post_request(email, enews_data, :put).body)
  end

end
