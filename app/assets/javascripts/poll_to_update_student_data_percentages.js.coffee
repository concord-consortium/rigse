DEFAULT_POLL_INTERVAL_IN_SECONDS = 10

window.poll_to_update_student_data_percentages = (options) ->

  # done if no poll url
  if not options.poll_url
    console.error "Missing poll_url option in poll_to_update_student_data_percentages() call" if console?.error
    return

  # get the poll interval or its default and then convert it to milliseconds if not already converted
  poll_interval = parseInt(options.poll_interval)
  poll_interval = DEFAULT_POLL_INTERVAL_IN_SECONDS if isNaN(poll_interval) or poll_interval < 1
  poll_interval *= 1000 if poll_interval < 1000

  # timestamp defines when data has been updated for the last time.
  # If we send it to server, it can optimize db query and return only updated offerings.
  data_timestamp = options.data_timestamp

  update_percentages = (status) ->
    for report_learner in status?.report_learners
      $offering = jQuery(".offering_for_student[data-offering_id='#{report_learner.offering_id}']")
      if $offering and report_learner.last_run
        $offering.find('.last_run').html(report_learner.last_run)
        $offering.find('.status_graphs .not_run').hide()
        $offering.find('.status_graphs .summary .progress').css({width: "#{report_learner.complete_percent}%"})
        $offering.find('.status_graphs .details .progress').each((idx) ->
          jQuery(this).css({width: "#{report_learner.subsection_complete_percent[idx]}%"})
        )
        $offering.find('.status_graphs .run_graph').show()

  # poll for percentage updates
  poll = ->
    jQuery.ajax options.poll_url,
      data:
        offerings_updated_after: data_timestamp
      success: (status) ->
        update_percentages status
        data_timestamp = status.timestamp
        setTimeout poll, poll_interval

  # wait for the initial poll
  setTimeout poll, poll_interval

