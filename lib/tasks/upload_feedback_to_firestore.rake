require "google/cloud/firestore"

embeddable_type_mapping = {
  "Embeddable::OpenResponse" => "open_response",
  "Embeddable::MultipleChoice" => "multiple_choice",
  "Embeddable::ImageQuestion" => "image_question",
  "Embeddable::Iframe" => "mw_interactive"
}

namespace :firestore do
  desc "Upload feedback to firestore"
  task :upload_feedback => :environment do
    source = ENV["SOURCE"] || "app.lara.docker"
    key_file = ENV["KEY"]
    abort "configuration is missing" unless source && key_file

    platform_id = ENV["SITE_URL"]
    platform_id_key = platform_id.gsub("/", "%")
    firestore = Google::Cloud::Firestore.new(
      project_id: "report-service-dev",
      credentials: key_file
    )

    # Activity feedback settings
    Portal::Offering.joins(:activity_feedbacks).uniq.find_each do |offering|
      puts "Processing offering #{offering.id}"
      doc = firestore.doc "sources/#{source}/feedback_settings/#{platform_id_key}-#{offering.id}-test"
      activity_settings = {}
      question_settings = {}
      rubric = nil

      if offering.runnable.template.is_a?(Activity)
        id = offering.runnable.url.match(/activities\/(\d+)/)[1]
        settings = Portal::OfferingActivityFeedback.for_offering_and_activity(offering, offering.runnable.template)
        activity_settings["activity-activity_#{id}"] = {
          textFeedbackEnabled: settings.enable_text_feedback,
          maxScore: settings.max_score,
          scoreType: settings.score_type,
          useRubric: settings.use_rubric,
        }
        rubric = settings.rubric
      end

      # Question feedback settings
      offering.metadata.each do |m|
        embeddable = m.embeddable
        if embeddable && (m.enable_text_feedback || m.max_score || m.enable_score)
          type = embeddable_type_mapping[m.embeddable_type]
          id = embeddable.external_id
          # Special case for Labbooks - their external_id includes Labbook class name. And firestore exects
          # different type too.
          if id.start_with?("Embeddable::Labbook_")
            id = id.gsub("Embeddable::Labbook_", "")
            type = "labbook"
          end
          question_settings[type + "_" + id] = {
            feedbackEnabled: m.enable_text_feedback,
            maxScore: m.max_score,
            scoreEnabled: m.enable_score
          }
        end
      end

      data = {
        activitySettings: activity_settings,
        questionSettings: question_settings,
        platformId: platform_id,
        contextId: offering.clazz.class_hash,
        resourceLinkId: offering.id.to_s,
        rubric: rubric
      }
      doc.set(data)
    end
  end
end

