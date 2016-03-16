class Client < ActiveRecord::Base
  attr_accessible :app_id, :app_secret, :name, :site_url, :domain_matchers
  has_many :access_grants, :dependent => :delete_all

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

  def updated_grant_for(user, time_to_live)
    grant = find_grant_for_user(user) || create_grant_for_user(user)
    grant.update_attribute(:access_token_expires_at, Time.now + time_to_live)
    grant
  end

  private
  def find_grant_for_user(user)
    access_grants.where({user_id: user.id, client_id:self.id}).first
  end

  def create_grant_for_user(user)
    user.access_grants.create(client_id:self.id, user_id:user.id)
  end
end
