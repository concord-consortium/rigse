class AccessGrant < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  before_create :generate_tokens
  
  attr_accessible :access_token, :access_token_expires_at, :client_id, :code, :refresh_token, :state, :user_id
  ExpireTime = 1.week
  def self.prune!
    delete_all(["access_token_expires_at < ?", 1.days.ago])
  end

  def self.authenticate(code, application_id)
    AccessGrant.where("code = ? AND client_id = ?", code, application_id).first
  end

  def generate_tokens
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{code}&response_type=code&state=#{state}"
    else
      redirect_uri + "?code=#{code}&response_type=code&state=#{state}"
    end
  end

  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, Time.now + ExpireTime)
  end
end
