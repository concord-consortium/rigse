class Import::DuplicateUser < ActiveRecord::Base
  self.table_name = :import_duplicate_users

  attr_accessible :login, :email, :duplicate_by, :data, :user_id, :import_id

  DUPLICATE_BY_LOGIN = 0
  DUPLICATE_BY_EMAIL = 1
  DUPLICATE_BY_LOGIN_AND_EMAIL = 2

  def duplicate_by_login?
    return duplicate_by == Import::DuplicateUser::DUPLICATE_BY_LOGIN
  end

  def duplicate_by_email?
    return duplicate_by == Import::DuplicateUser::DUPLICATE_BY_EMAIL
  end

  def duplicate_by_login_and_email?
    return duplicate_by == Import::DuplicateUser::DUPLICATE_BY_LOGIN_AND_EMAIL
  end
end