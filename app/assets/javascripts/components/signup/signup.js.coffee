{div} = React.DOM

modulejs.define 'components/signup/signup',
[
  'components/signup/basic_data_form',
  'components/signup/student_form',
  'components/signup/teacher_form',
  'components/signup/student_registration_complete',
  'components/signup/teacher_registration_complete'
],
(
  BasicDataFormClass,
  StudentFormClass,
  TeacherFormClass,
  StudentRegistrationCompleteClass,
  TeacherRegistrationCompleteClass
) ->
  BasicDataForm = React.createFactory BasicDataFormClass
  StudentForm = React.createFactory StudentFormClass
  TeacherForm = React.createFactory TeacherFormClass
  StudentRegistrationComplete = React.createFactory StudentRegistrationCompleteClass
  TeacherRegistrationComplete = React.createFactory TeacherRegistrationCompleteClass

  React.createClass
    getInitialState: ->
      basicData: null
      studentData: null
      teacherData: null

    onBasicDataSubmit: (data) ->
      @setState basicData: data

    onStudentRegistration: (data) ->
      @setState studentData: data

    onTeacherRegistration: (data) ->
      @setState teacherData: data

    getStepNumber: ->
      {basicData, studentData, teacherData} = @state
      return 1 unless basicData
      return 2 if basicData && !studentData && !teacherData
      return 3

    render: ->
      {signupText} = @props
      {basicData, studentData, teacherData} = @state
      (div {className: 'signup-form'},
        (div {className: 'title'}, 'Sign Up')
        (div {className: 'step'}, "Step #{@getStepNumber()} of 3")
        if studentData
          (StudentRegistrationComplete {data: studentData})
        else if teacherData
          (TeacherRegistrationComplete {})
        else if !basicData
          (BasicDataForm {signupText: signupText, onSubmit: @onBasicDataSubmit})
        else if basicData.type == 'student'
          (StudentForm {basicData: basicData, onRegistration: @onStudentRegistration})
        else if basicData.type == 'teacher'
          (TeacherForm {basicData: basicData, onRegistration: @onTeacherRegistration})
      )

Portal.renderSingupForm = (selectorOrElement, signupText = 'Sign Up') ->
  Signup = React.createFactory modulejs.require('components/signup/signup')
  ReactDOM.render Signup(signupText: signupText), jQuery(selectorOrElement)[0]
