require 'capybara/mechanize/cucumber'

class Capybara::Mechanize::Browser

  # custom post_data method which can handle passing a raw string as the request body.
  def post_data_with_raw(params)
    return params if params.is_a? String
    return post_data_without_raw(params)
  end

  alias_method_chain :post_data, :raw
end
