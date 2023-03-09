class Saveable::OpenResponse < ApplicationRecord
  self.table_name = "saveable_open_responses"

  belongs_to :learner,        :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  belongs_to :open_response,  :class_name => 'Embeddable::OpenResponse'

  [:prompt, :name].each { |m| delegate m, :to => :open_response }

  def embeddable
    open_response
  end
end
