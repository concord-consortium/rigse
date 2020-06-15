// Mapping of API data to React component props.

const feedbackOptionsMapping = data => ({
  scoreFeedbackEnabled: data.score_feedback_enabled,
  textFeedbackEnabled: data.text_feedback_enabled,
  rubricFeedbackEnabled: data.rubric_feedback_enabled,
  scoreType: data.score_type,
  maxScore: data.max_score,
  rubric: data.rubric
})

const feedbackMapping = data => ({
  hasBeenReviewed: data.has_been_reviewed,
  score: data.score,
  textFeedback: data.text_feedback,
  rubricFeedback: data.rubric_feedback
})

const detailedProgressMapping = data => ({
  activityId: data.activity_id,
  activityName: data.activity_name,
  progress: data.progress,
  reportUrl: data.learner_activity_report_url,
  feedback: data.feedback && feedbackMapping(data.feedback)
})

export const studentMapping = data => ({
  id: data.user_id,
  name: data.last_name + ', ' + data.first_name,
  lastRun: data.last_run && new Date(data.last_run),
  totalProgress: data.total_progress,
  startedActivity: data.started_activity,
  reportUrl: data.learner_report_url,
  detailedProgress: data.detailed_progress && data.detailed_progress.map(dp => detailedProgressMapping(dp))
})

export const reportableActivityMapping = data => ({
  id: data.id,
  name: data.name,
  reportUrl: data.activity_report_url,
  feedbackOptions: data.feedback_options && feedbackOptionsMapping(data.feedback_options)
})
