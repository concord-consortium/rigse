// Mapping of API data to React component props.

const feedbackOptionsMapping = (data: any) => ({
  scoreFeedbackEnabled: data.score_feedback_enabled,
  textFeedbackEnabled: data.text_feedback_enabled,
  rubricFeedbackEnabled: data.rubric_feedback_enabled,
  scoreType: data.score_type,
  maxScore: data.max_score,
  rubric: data.rubric
});

const feedbackMapping = (data: any) => ({
  hasBeenReviewed: data.has_been_reviewed,
  score: data.score,
  textFeedback: data.text_feedback,
  rubricFeedback: data.rubric_feedback
});

const detailedProgressMapping = (data: any) => ({
  activityId: data.activity_id,
  activityName: data.activity_name,
  progress: data.progress,
  reportUrl: data.learner_activity_report_url,
  feedback: data.feedback && feedbackMapping(data.feedback)
});

export const studentMapping = (data: any, researcher = false) => ({
  id: data.user_id,

  // In the researcher view (anonymized), the .name is presented in a more readable and anonymized format,
  // e.g., "Student 123" instead of "123, Student".
  name: researcher ? data.name : data.last_name + ", " + data.first_name,

  lastRun: data.last_run && new Date(data.last_run),
  totalProgress: data.total_progress,
  startedActivity: data.started_activity,
  reportUrl: data.learner_report_url,
  detailedProgress: data.detailed_progress?.map((dp: any) => detailedProgressMapping(dp)),
  active: data.active,
  locked: data.locked,
});

export const reportableActivityMapping = (data: any) => ({
  id: data.id,
  name: data.name,
  reportUrl: data.activity_report_url,
  feedbackOptions: data.feedback_options && feedbackOptionsMapping(data.feedback_options)
});
