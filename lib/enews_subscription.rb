module EnewsSubscription

  @mc_api_key = ENV['MAILCHIMP_API_KEY']
  @mc_list_id = ENV['MAILCHIMP_API_LISTID']
  @mc_uri = ENV['MAILCHIMP_API_URI']

  def self.get_enews_subscription(email)
    @mc_data = {
      'email_address' => "#{email}"
      }
    @digest = Digest::MD5.hexdigest("#{email}")

    uri = URI("#{@mc_uri}/#{@mc_list_id}/members/#{@digest}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.path, 'Content-type' => 'application/json')
    req.basic_auth("user", "#{@mc_api_key}")
    req.body = @mc_data.to_json
    response = http.request(req)
    response_data = JSON.parse(response.body)

    return response_data
  end

  def self.update_enews_subscription(email, status, first_name, last_name)
    @mc_data = {
      'email_address' => "#{email}",
      'status' => "#{status}",
      'merge_fields' => {
        'FNAME' => "#{first_name}",
        'LNAME' => "#{last_name}"
        }
      }
    @digest = Digest::MD5.hexdigest("#{email}")

    uri = URI("#{@mc_uri}/#{@mc_list_id}/members/#{@digest}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Put.new(uri.path, 'Content-type' => 'application/json')
    req.basic_auth("user", "#{@mc_api_key}")
    req.body = @mc_data.to_json
    response = http.request(req)
    response_data = JSON.parse(response.body)

    return response_data
  end

end


# EnewsSubscription::get_enews_subscription(email)
# EnewsSubscription::update_enews_subscription(email, status, first_name, last_name)
