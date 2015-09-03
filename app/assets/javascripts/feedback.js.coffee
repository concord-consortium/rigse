{div, button, span, input, img, textarea, a, iframe, select, option, table, tbody, tr, td} = React.DOM

# this is the only "exported" function - the rest of the code is automatically wrapped in a IIFE by CoffeeScript
window.get_feedback_popup = (options) ->

  lightbox = new Lightbox
    content: "<div id='windowcontent' style='padding:10px'><div id='feedback_popup'></div></div>",
    title: "Feedback: Question #{options.question_number}"

  React.render FeedbackPopup({options: options, lightbox: lightbox}), document.getElementById("feedback_popup")

  lightbox.handle.setSize 750, 600
  lightbox.handle.center()

PreviousAnswerAndFeedbackItem = React.createFactory React.createClass

  displayName: 'PreviousAnswerAndFeedbackItem'

  getInitialState: ->
    show: false

  toggleShow: (e) ->
    e.preventDefault()
    @setState show: not @state.show

  renderShowHide: ->
    (a {href: '#', className: 'feedback_showhide', onClick: @toggleShow}, if @state.show then 'Hide' else "Show - #{@props.item.date}")

  renderImageAnswerFeedback: (item) ->
    (span {},
      if @state.show
        (div {className: 'feedback_answer'},
          (a {href: item.answer, target: '_blank'},
            (img {src: item.answer})
          )
          (div {className: 'feedback-text'}, "#{item.feedback} (#{item.date})")
        )
      @renderShowHide()
    )

  renderOpenResponseAnswerFeedback: (item) ->
    (span {},
      item.answer
      (div {className: 'inline-feedback-text'}, "#{item.feedback} (#{item.date})")
    )

  renderMultipleChoiceAnswerFeedback: (item) ->
    answers = for answer in item.answer
      answer.answer
    (span {},
      answers.join(', ')
      (div {className: 'inline-feedback-text'}, "#{item.feedback} (#{item.date})")
    )

  renderIFrameAnswerFeedback: (item) ->
    (span {},
      if @state.show
        (div {className: 'feedback_answer'},
          (iframe {src: answer.answer})
          (div {className: 'feedback-text'}, "#{item.feedback} (#{item.date})")
        )
      @renderShowHide()
    )

  render: ->
    switch @props.answer.embeddable_type.split('::')[1]
      when 'ImageQuestion' then @renderImageAnswerFeedback @props.item
      when 'OpenResponse' then @renderOpenResponseAnswerFeedback @props.item
      when 'MultipleChoice' then @renderMultipleChoiceAnswerFeedback @props.item
      when 'Iframe' then @renderIFrameAnswerFeedback @props.item
      else 'Unknown answer type!'

FeedbackPopupGroupSelectRadio = React.createFactory React.createClass

  displayName: 'FeedbackPopupGroupSelectRadio'

  radioSelected: ->
    @props.radioSelected @props.value

  render: ->
    (input {type: 'radio', name: 'groupType', value: @props.value, checked: @props.value is @props.groupType, onChange: @radioSelected}, @props.children)

FeedbackPopupGroupSelect = React.createFactory React.createClass

  displayName: 'FeedbackPopupGroupSelect'

  getInitialState: ->
    selectedStudent: 0

  selectSelected: ->
    learnerId = (React.findDOMNode @refs.select).value
    @props.scrollToGroup learnerId if learnerId
    @setState selectedStudent: learnerId

  radioSelected: (groupType) ->
    @setState selectedStudent: 0
    @props.selectGroupType groupType

  render: ->
    groups = @props.groups[@props.selectedGroupType]
    (div {className: 'feedback-student-list'},
      (span {className: 'feedback-student-list-view-answer'}, 'View answer by:')
      if groups.length > 0
        (select {ref: 'select', value: @state.selectedStudent, onChange: @selectSelected},
          (option {value: 0}, 'Select a student or group...')
          for group in groups
            (option {value: group.id}, group.name)
        )
      else
        (span {}, @state.emptyListMessage or 'No students were found')

      (span {className: 'feedback-student-list-show'}, 'Show:')
      (FeedbackPopupGroupSelectRadio {value: 'all', groupType: @props.selectedGroupType, radioSelected: @radioSelected}, 'All Students')
      (FeedbackPopupGroupSelectRadio {value: 'needsFeedback', groupType: @props.selectedGroupType, radioSelected: @radioSelected}, 'Students Who Need Feedback')
    )

ScoreBox = React.createFactory React.createClass

  displayName: 'ScoreBox'

  getInitialState: ->
    score: @props.score

  changed: (e) ->
    value = (e.target.value + String.fromCharCode(e.keyCode)).replace /^\D/g, ''
    intValue = parseInt value, 10
    @setState score: if isNaN intValue then '' else intValue
    @props.changed? if isNaN intValue then null else intValue

  render: ->
    percentage = Math.round((@state.score / @props.maxScore) * 100)
    (div {},
      (input {ref: 'score', type: 'text', value: @state.score, onChange: @changed, disabled: @props.disabled})
      if isFinite(percentage) and not isNaN(percentage)
        (div {className: 'feedback-score-percentage'}, "(#{percentage}%)")
    )

FeedbackArea = React.createFactory React.createClass

  displayName: 'FeedbackArea'

  getInitialState: ->
    value: @props.answer.current_feedback

  feedbackChanged: ->
    value = (React.findDOMNode @refs.feedback).value
    @props.answer.new_feedback = value
    @setState
      value: value
      dirty: true
    @props.setDirty true

  scoreChanged: (newScore) ->
    @props.answer.new_score = newScore

  copyMostRecentFeedback: (e) ->
    e.preventDefault()
    if @props.answer.previous_answers_and_feedback.length > 0
      @setState value: @props.answer.previous_answers_and_feedback.slice(-1)[0].feedback

  render: ->
    disabled = (@props.maxScore is 0) or (@props.maxScore is null)
    (div {},
      (div {className: 'feedback_label'},
        'Feedback'
        if @props.answer.previous_answers_and_feedback.length > 0
          (span {},
            ' ('
            (a {href: '#', onClick: @copyMostRecentFeedback}, 'copy most recent')
            ')'
          )
      )
      (textarea {ref: 'feedback', id: "feedback_textarea_#{@props.answer.learner_id}", value: @state.value, onChange: @feedbackChanged, placeholder: 'Your feedback...'})
      if @props.allowScoring
        (div {className: 'feedback_score_value'},
          (div {}, 'Score')
          (ScoreBox {score: @props.answer.score, disabled: disabled, maxScore: @props.maxScore, changed: @scoreChanged})
        )
    )

FeedbackPopup = React.createFactory React.createClass

  displayName: 'FeedbackPopup'

  getInitialState: ->
    loading: true
    error: null
    dirty: false
    saveMessage: null
    groups:
      all: []
      needsFeedback: []
    selectedGroupType: 'all'
    maxScore: null
    allowScoring: false

  componentDidUpdate: ->
    #(React.findDOMNode @refs.feedback).focus() if @refs.feedback

  componentWillMount: ->
    # get the report json and find the reqested item
    jQuery.ajax
      type: 'get'
      url: "/portal/offerings/#{@props.options.offering_id}/report.json"
      error: =>
        @setState error: 'Unable to load report data'
      success: (data) =>
        groupsByAnswer = {}
        for answer in data.report
          if answer.question_number is @props.options.question_number
            key = JSON.stringify
              answer: answer.answer
              current_feedback: answer.current_feedback
              previous_answers_and_feedback: answer.previous_answers_and_feedback
              score: answer.score
            groupsByAnswer[key] ?= []
            groupsByAnswer[key].push answer

        learnerGroupId = 0
        id = 1
        groups =
          all: []
          needsFeedback: []
        for key, answers of groupsByAnswer
          group =
            id: id++
            name: (answer.learner_name for answer in answers).join ', '
            answer: answers[0]
            allAnswers: answers
          groups.all.push group
          groups.needsFeedback.push group if answer.answer and (answer.current_feedback is null or answer.current_feedback.length is 0)

          # save the group with the requested learner
          if @props.options.learner_id and not learnerGroupId
            for answer in answers
              learnerGroupId = group.id if answer.learner_id is @props.options.learner_id

        @setState
          loading: false
          groups: groups
          maxScore: groups.all[0]?.answer.max_score
          allowScoring: groups.all[0]?.answer.enable_score

        if @props.options.learner_id and learnerGroupId
          setTimeout (=> @scrollToGroup learnerGroupId, 0), 0

  save: ->
    # expand out group answers to save
    answers = []
    updateAnswer = []
    for group in @state.groups.all
      feedbackChanged = group.answer.new_feedback? and group.answer.new_feedback isnt group.answer.current_feedback
      scoreChanged = group.answer.new_score? and group.answer.new_score isnt group.answer.score
      if feedbackChanged or scoreChanged
        for answer in group.allAnswers
          answers.push
            saveable_id: answer.saveable_id
            embeddable_type: answer.embeddable_type
            feedback_changed: feedbackChanged
            new_feedback: group.answer.new_feedback
            score_changed: scoreChanged
            new_score: group.answer.new_score
          updateAnswer.push answer

    firstAnswer = @state.groups.all[0].answer

    @setState saveMessage: 'Saving...'
    jQuery.ajax
      type: 'post'
      url: "/portal/offerings/#{@props.options.offering_id}/update_feedback.json"
      dataType: 'json',
      contentType: 'application/json',
      data: JSON.stringify
        answers: answers
        enable_score: @state.allowScoring
        max_score: @state.maxScore
        embeddable_type: firstAnswer.embeddable_type
        embeddable_id: firstAnswer.embeddable_id
      success: =>
        for answer in updateAnswer
          if answer.new_feedback?
            jQuery("#feedback_#{answer.question_number}_#{answer.learner_id}").html(answer.new_feedback.escapeHTML()).show()
            answer.current_feedback = answer.new_feedback
          if answer.new_score?
            jQuery("#feedback_score_#{answer.question_number}_#{answer.learner_id}").html(answer.new_score).show()
            answer.score = answer.new_score
        @setState dirty: false
        @close()
      error: =>
        @setState saveMessage: 'Unable to save feedback!'

  cancel: ->
    if not @state.dirty or confirm('You have unsaved feedback.  Are you sure you want to leave without saving?')
      @close()

  close: ->
    window.location.hash = ''
    @props.lightbox.close()

  setDirty: (dirty) ->
    @setState
      dirty: dirty

  scrollToGroup: (groupId, duration=250) ->
    scrollArea = jQuery(".feedback-student-answers")
    group = jQuery("#feedback_group_#{groupId}")
    top = scrollArea.scrollTop() + group.offset().top - scrollArea.offset().top
    scrollArea.animate({scrollTop: top}, duration)
    group.find('textarea').focus()

  maxScoreChanged: (score) ->
    @setState
      maxScore: score
      dirty: true

  scoreCheckboxChanged: ->
    @setState
      allowScoring: (React.findDOMNode @refs.scoreCheckbox).checked
      dirty: true

  selectGroupType: (groupType) ->
    @setState selectedGroupType: groupType

  renderHeader: (firstAnswer) ->
    (div {className: 'feedback_header'},
      (div {className: 'feedback_enable_score'},
        (div {},
          (input {ref: 'scoreCheckbox', type: 'checkbox', onChange: @scoreCheckboxChanged, checked: @state.allowScoring}, 'Score?')
        )
        if @state.allowScoring
          (div {},
            (div {}, 'Max. Score')
            (ScoreBox {score: @state.maxScore, changed: @maxScoreChanged})
          )
      )
      (div {className: 'feedback_prompt', dangerouslySetInnerHTML: {__html: if firstAnswer.question.prompt? then firstAnswer.question.prompt else '&nbsp;'}})
    )

  renderImageAnswer: (answer) ->
    (div {className: 'feedback_answer'},
      if answer.question.drawing_prompt?
        (div {className: 'feedback_drawing_prompt', dangerouslySetInnerHTML: {__html: answer.question.drawing_prompt}})
      (a {href: answer.answer, target: '_blank'},
        (img {src: answer.answer})
      )
    )

  renderOpenResponseAnswer: (answer) ->
    (div {className: 'feedback_answer'},
      (div {}, answer.answer)
    )

  renderMultipleChoiceAnswer: (answer) ->
    (div {className: 'feedback_answer'},
      for answer in answer.answer
        (div {}, answer.answer)
    )

  renderIFrameAnswer: (answer) ->
    (div {className: 'feedback_answer'},
      (iframe {src: answer.answer})
    )

  render: ->
    if @state.error
      (div {},
        (div {className: 'feedback_error_message'}, @state.error)
        (div {className: 'feedback_buttons'},
          (button {onClick: @close}, 'Cancel')
        )
      )
    else if @state.loading or @state.groups.all.length is 0
      (div {},
        (div {className: 'feedback_loading_message'}, if @state.loading then 'Loading...' else 'No answers were found for feedback.')
        (div {className: 'feedback_buttons'},
          (button {onClick: @close}, 'Cancel')
        )
      )
    else
      (div {},
        (div {className: 'feedback_content', ref: 'content'},
          @renderHeader @state.groups.all[0].answer
          (FeedbackPopupGroupSelect {groups: @state.groups, selectedGroupType: @state.selectedGroupType, selectGroupType: @selectGroupType, scrollToGroup: @scrollToGroup})
          if @state.groups[@state.selectedGroupType].length > 0
            (div {className: 'feedback-student-answers'},
              for group, i in @state.groups[@state.selectedGroupType]
                (div {id: "feedback_group_#{group.id}", className: 'feedback-student-answer', key: group.id},
                  (div {className: 'feedback-student-name'}, group.name)
                  if group.answer.answer?
                    (div {},
                      switch group.answer.embeddable_type.split('::')[1]
                        when 'ImageQuestion' then @renderImageAnswer group.answer
                        when 'OpenResponse' then @renderOpenResponseAnswer group.answer
                        when 'MultipleChoice' then @renderMultipleChoiceAnswer group.answer
                        when 'Iframe' then @renderIFrameAnswer group.answer
                        else 'Unknown answer type!'
                      (div {className: 'feedback_container'},
                        (FeedbackArea {key: i, answer: group.answer, setDirty: @setDirty, maxScore: @state.maxScore, allowScoring: @state.allowScoring})
                        if group.answer.previous_answers_and_feedback.length > 0
                          (div {className: 'feedback-all-feedback'},
                            (div {}, 'Previous feedback:')

                            # could not get css to align the list bullet to top so I went with a table
                            (table {},
                              (tbody {},
                                for answerAndFeedback in group.answer.previous_answers_and_feedback
                                  (tr {},
                                    (td {className: 'feedback-bullet', dangerouslySetInnerHTML: {__html: '&#8226;'}})
                                    (td {}, (PreviousAnswerAndFeedbackItem {answer: group.answer, item: answerAndFeedback}))
                                  )
                              )
                            )
                          )
                      )
                    )
                  else
                    (div {className: 'feedback_not_answered'}, 'This question has not been answered.')
                )
            )
          else
            (div {className: 'feedback-student-no-answers'},
              (div {}, 'Sorry, no students were found.')
            )
        )
        if @state.saveMessage
          (div {className: 'feedback_save_message'}, @state.saveMessage)
        (div {className: 'feedback_buttons'},
          (button {onClick: @save, disabled: not @state.dirty}, 'Save')
          (button {onClick: @cancel}, 'Cancel')
        )
      )

# TODO: remove before integrating with master
hideNPlus1 = ->
  nPlus1 = jQuery("div[data-is-bullet-footer]")
  if nPlus1.length > 0
    nPlus1.hide()
  else
    setTimeout hideNPlus1, 250
setTimeout hideNPlus1, 250

