class NotificationsController < ApplicationController

  # action which triggers loading the latest learner data from the couch database
  def assessments
    db = params[:db]
    if db
      importer = Assessments::LearnerDataImporter.new(db)
      importer.run
    end
  end
end
