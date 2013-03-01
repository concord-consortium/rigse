class MiscMetalController < ActionController::Metal
  def time
    self.status = 200
    self.content_type = 'text/plain'
    self.response_body = "#{(Time.now.utc.to_f * 1000).to_i}"
  end
end
