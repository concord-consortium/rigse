class Saveable::Sparks::MeasuringResistance < ActiveRecord::Base
  self.table_name = "saveable_sparks_measuring_resistance"

  attr_accessible :learner_id, :offering_id

  belongs_to :learner, :class_name => 'Portal::Learner'
  belongs_to :offering,        :class_name => 'Portal::Offering'

  has_many :reports, -> { order :position },
    :class_name => "Saveable::Sparks::MeasuringResistanceReports"

  def answer
    self.reports.last.answer
  end
end
