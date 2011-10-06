class HelpRequest < ActiveRecord::Base
  validates_presence_of :name, :message => "Please enter your full name."
  validates_presence_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Please enter a valid email address."
  validates_presence_of :more_info, :message => "Please write a few words describing the issue you're experiencing."
end
