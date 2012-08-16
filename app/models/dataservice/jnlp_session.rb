class Dataservice::JnlpSession < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user

  before_create :create_token

  def create_token
    # create a random string which will be used to verify permission to view this blob
    self.token = UUIDTools::UUID.timestamp_create.hexdigest
  end

  def access_user
    # keep track of user accesses so we can look for orphaned sessions
    # and ones that accessed multiple times
    access_count = access_count + 1
    save!
    (access_count == 1) ? user : nil
  end

  def self.get_user_from_token(token)
    jnlp_session = self.find_by_token(token)
    jnlp_session.access_user
  end
end
