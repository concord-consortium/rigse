class MiscMetalController < ActionController::Metal
  def time
    self.status = 200
    self.content_type = 'text/plain'
    self.response_body = "#{((Time.now.to_f - Time.now.gmt_offset) * 1000).to_i}"
  end
end
