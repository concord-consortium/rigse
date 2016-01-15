class Client < ActiveRecord::Base
  attr_accessible :app_id, :app_secret, :name, :site_url, :domain_matchers
  def self.authenticate(app_id, app_secret)
    where(["app_id = ? AND app_secret = ?", app_id, app_secret]).first
  end

  def valid_from_referer?(referer)
    return true unless enforce_referrer?
    domain_matchers.split(/\s+/).each do |matcher|
      return true if (/^https?:\/\/#{matcher}/ =~ referer)
    end
    return false
  end

  def enforce_referrer?
    if domain_matchers.blank?
      false
    else
      true
    end
  end
end
