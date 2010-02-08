class Saveable::Sparks::MeasuringResistance < ActiveRecord::Base
  set_table_name "saveable_sparks_measuring_resistance"

  belongs_to :learner, :class_name => 'Portal::Learner'

  has_many :reports, :order => :position, :class_name => "Saveable::Sparks::MeasuringResistanceReport"

  def answer
    self.reports.last.answer
  end
end
