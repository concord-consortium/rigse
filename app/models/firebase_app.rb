class FirebaseApp < ActiveRecord::Base
  self.table_name = :firebase_apps

  validates_presence_of :name, :message => "can't be blank"
  validates_presence_of :client_email, :message => "can't be blank"
  validates_presence_of :private_key, :message => "can't be blank"
end
