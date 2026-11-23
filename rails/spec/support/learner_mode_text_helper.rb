# The text added to error messages after a learner mode switch in another tab. The app defines
# it in ApplicationController. The specs write it out here, so a wording change breaks them.
module LearnerModeTextHelper
  SWITCHED_TO_LEARNER_TEXT = "That page or action isn't available in learner mode. " \
    "You may have switched to learner mode in another tab. " \
    "Use 'Switch back to teacher' in the sidebar to go back."
  SWITCHED_TO_TEACHER_TEXT = "That page or action isn't available to your teacher account. " \
    "You may have switched back to teacher in another tab. " \
    "Use 'Switch to Learner Mode (LM)' in the sidebar to go back."
  SWITCHED_TO_LEARNER_BACKGROUND_TEXT = "You may have switched to learner mode in another tab, " \
    "so this page is out of date. Reload the page to continue."
  SWITCHED_TO_TEACHER_BACKGROUND_TEXT = "You may have switched back to teacher in another tab, " \
    "so this page is out of date. Reload the page to continue."
end
