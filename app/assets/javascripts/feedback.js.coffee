{div, button, span, input, img, textarea, a, iframe, ol, li} = React.DOM

# this is the only "exported" function - the rest of the code is automatically wrapped in a IIFE by CoffeeScript
window.get_feedback_popup = (options) ->

  lightbox = new Lightbox
    content: "<div id='windowcontent' style='padding:10px'><div id='feedback_popup'></div></div>",
    title: "Feedback"

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
    (a {href: '#', className: 'feedback_showhide', onClick: @toggleShow}, if @state.show then 'Hide' else 'Show')

  renderImageAnswerFeedback: (item) ->
    (span {},
      if @state.show
        (div {className: 'feedback_answer'},
          (a {href: item.answer, target: '_blank'},
            (img {src: item.answer})
          )
        )
      @renderShowHide()
      (span {}, " -> #{item.feedback}")
    )

  renderOpenResponseAnswerFeedback: (item) ->
    (span {}, "#{item.answer} -> #{item.feedback}")

  renderMultipleChoiceAnswerFeedback: (item) ->
    answers = for answer in item.answer
      answer.answer
    (span {}, "#{answers.join(', ')} -> #{item.feedback}")

  renderIFrameAnswerFeedback: (item) ->
    (span {},
      if @state.show
        (div {className: 'feedback_answer'},
          (iframe {src: answer.answer})
        )
      @renderShowHide()
      (span {}, " -> #{item.feedback}")
    )

  render: ->
    switch @props.answer.saveable_type
      when 'ImageQuestion' then @renderImageAnswerFeedback @props.item
      when 'OpenResponse' then @renderOpenResponseAnswerFeedback @props.item
      when 'MultipleChoice' then @renderMultipleChoiceAnswerFeedback @props.item
      when 'Iframe' then @renderIFrameAnswerFeedback @props.item
      else 'Unknown answer type!'

FeedbackPopupStudentItem = React.createFactory React.createClass

  displayName: 'FeedbackPopupStudentItem'

  scrollToStudent: (e) ->
    e.preventDefault()
    @props.scrollToStudent @props.learner_id

  render: ->
    (a {href: "#", ref: 'link', onClick: @scrollToStudent}, @props.learner_name)

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
      if not isNaN percentage
        (div {}, "#{percentage}%")
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

  render: ->
    disabled = (@props.maxScore is 0) or (@props.maxScore is null)
    (div {},
      (div {className: 'feedback_score_value'},
        (div {}, 'Score')
        (ScoreBox {score: @props.answer.score, disabled: disabled, maxScore: @props.maxScore})
      )
      (div {}, 'Feedback')
      (textarea {ref: 'feedback', id: "feedback_textarea_#{@props.answer.learner_id}", value: @state.value, onChange: @feedbackChanged, placeholder: 'Your feedback...'})
    )

FeedbackPopup = React.createFactory React.createClass

  displayName: 'FeedbackPopup'

  getInitialState: ->
    loading: true
    dirty: false
    saveMessage: null
    maxScore: null

  componentDidUpdate: ->
    #(React.findDOMNode @refs.feedback).focus() if @refs.feedback

  componentWillMount: ->
    # get the report json and find the reqested item
    jQuery.ajax
      type: 'get'
      url: "/portal/offerings/#{@props.options.offering_id}/report.json"
      success: (data) =>
        answers = []
        withAnswers = []
        withoutAnswers = []
        for answer in data.report
          if answer.question_number is @props.options.question_number
            answers.push answer
            if answer.answer?
              withAnswers.push answer
            else
              withoutAnswers.push answer
        @setState
          loading: false
          answers: answers
          withAnswers: withAnswers
          withoutAnswers: withoutAnswers
        if @props.options.learner_id
          setTimeout (=> @scrollToStudent @props.options.learner_id), 0

  save: ->
    ajaxData = []
    updateAnswer = []
    for answer in @state.answers
      if answer.new_feedback? and answer.new_feedback isnt answer.current_feedback
        ajaxData.push
          saveable_id: answer.saveable_id
          saveable_type: answer.saveable_type
          new_feedback: answer.new_feedback
        updateAnswer.push answer

    if ajaxData.length > 0
      @setState saveMessage: 'Saving...'
      jQuery.ajax
        type: 'post'
        url: "/portal/offerings/#{@props.options.offering_id}/update_feedback.json"
        dataType: 'json',
        contentType: 'application/json',
        data: JSON.stringify {answers: ajaxData}
        success: =>
          for answer in updateAnswer
            jQuery("#feedback_#{answer.question_number}_#{answer.learner_id}").html(answer.new_feedback.escapeHTML())
            answer.current_feedback = answer.new_feedback
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

  scrollToStudent: (learner_id) ->
    top = jQuery("#feedback_for_student_#{learner_id}").offset().top
    jQuery(".ui-window .content").animate({scrollTop: top}, 250)
    jQuery("#feedback_textarea_#{learner_id}").focus()

  maxScoreChanged: (score) ->
    @setState maxScore: score

  renderHeader: (firstAnswer) ->
    (div {className: 'feedback_header'},
      (div {className: 'feedback_score_value'},
        (div {}, 'Max. Score')
        (ScoreBox {score: @state.maxScore, changed: @maxScoreChanged})
      )
      (div {className: 'feedback_question_number'}, "Question #{firstAnswer.question_number}")
      if firstAnswer.question.prompt?
        (div {className: 'feedback_prompt', dangerouslySetInnerHTML: {__html: firstAnswer.question.prompt}})
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

  renderAnswerList: (label, answers) ->
    (div {},
      "#{label} (#{answers.length}): "
      if answers.length > 0
        for answer, i in answers
          (span {key: answer.learner_id},
            (FeedbackPopupStudentItem {learner_id: answer.learner_id, learner_name: answer.learner_name, scrollToStudent: @scrollToStudent})
            if i isnt answers.length - 1
              ', '
          )
      else
        "None"
    )

  renderAnswerLists: ->
    (div {className: 'feedback-student-counts'},
      @renderAnswerList 'Answered', @state.withAnswers
      @renderAnswerList 'Not Answered', @state.withoutAnswers
    )

  render: ->
    if @state.loading or @state.answers.length is 0
      (div {},
        (div {className: 'feedback_loading_message'}, if @state.loading then 'Loading...' else 'No answers were found for feedback.')
        (div {className: 'feedback_buttons'},
          (button {onClick: @close}, 'Cancel')
        )
      )
    else
      (div {},
        (div {className: 'feedback_content', ref: 'content'},
          @renderHeader @state.answers[0]
          @renderAnswerLists()
          for answer, i in @state.answers
            (div {className: 'feedback-student-answer', key: answer.learner_id},
              (div {className: 'feedback-student-name', id: "feedback_for_student_#{answer.learner_id}"}, answer.learner_name)
              if answer.answer?
                (div {},
                  switch answer.saveable_type
                    when 'ImageQuestion' then @renderImageAnswer answer
                    when 'OpenResponse' then @renderOpenResponseAnswer answer
                    when 'MultipleChoice' then @renderMultipleChoiceAnswer answer
                    when 'Iframe' then @renderIFrameAnswer answer
                    else 'Unknown answer type!'
                  if answer.previous_answers_and_feedback.length > 0
                    (div {className: 'feedback-all-feedback'},
                      (div {}, 'Previous feedback:')
                      (ol {},
                        for answerAndFeedback in answer.previous_answers_and_feedback
                          (li {}, (PreviousAnswerAndFeedbackItem {answer: answer, item: answerAndFeedback}))
                      )
                    )
                  (FeedbackArea {key: i, answer: answer, setDirty: @setDirty, maxScore: @state.maxScore})
                )
              else
                (div {className: 'feedback_not_answered'}, 'This question has not been answered.')
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

