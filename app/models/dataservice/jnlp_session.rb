class Dataservice::JnlpSession < ActiveRecord::Base
  attr_accessible :user, :access_count

  belongs_to :user
  has_many :installer_reports

  before_create :create_token

  def create_token
    self.token = UUIDTools::UUID.timestamp_create.hexdigest
  end

  def access_user
    # keep track of user accesses so we can look for orphaned sessions
    # and ones that accessed multiple times
    increment!(:access_count)
    (self.access_count == 1) ? user : nil
  end

  def self.get_user_from_token(token)
    jnlp_session = self.find_by_token(token)
    jnlp_session ? jnlp_session.access_user : nil
  end
end
