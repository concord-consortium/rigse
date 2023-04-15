const DEFAULT_POLL_INTERVAL_IN_SECONDS = 10;

window.poll_to_update_student_data_percentages = function(options) {

  // done if no poll url
  if (!options.poll_url) {
    if (console) {
      console.error("Missing poll_url option in poll_to_update_student_data_percentages() call");
    }
    return;
  }

  // get the poll interval or its default and then convert it to milliseconds if not already converted
  let poll_interval = parseInt(options.poll_interval);
  if (isNaN(poll_interval) || (poll_interval < 1)) { poll_interval = DEFAULT_POLL_INTERVAL_IN_SECONDS; }
  if (poll_interval < 1000) { poll_interval *= 1000; }

  // timestamp defines when data has been updated for the last time.
  // If we send it to server, it can optimize db query and return only updated offerings.
  let {
    data_timestamp
  } = options;

  const update_percentages = (status) => {
    if (status != null) {
      for (var report_learner of status.report_learners) {
        const $offering = jQuery(`.offering_for_student[data-offering-id='${report_learner.offering_id}']`);
        if ($offering && report_learner.last_run) {
          $offering.find('.last_run').html(report_learner.last_run);
        }
      }
    }
  };

  // poll for percentage updates
  var poll = () => jQuery.ajax(options.poll_url, {
    data: {
      offerings_updated_after: data_timestamp
    },
    success(status) {
      update_percentages(status);
      data_timestamp = status.timestamp;
      setTimeout(poll, poll_interval);
    }
  }
  );

  // wait for the initial poll
  setTimeout(poll, poll_interval);
};
