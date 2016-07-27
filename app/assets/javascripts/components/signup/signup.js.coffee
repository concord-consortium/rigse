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

    getDefaultProps: ->
      signupText: "Sign Up for #{Portal.siteName}!"
      # When user is anonymous, we need to ask about all the information (email, login, password).
      # However, sometimes users are using SSO and basic user object can be already created. Then we only
      # need to create Portal-specific models (student or teacher).
      anonymous: Portal.currentUser.isAnonymous

    onBasicDataSubmit: (data) ->
      # Save the current path. Backend can use that information to redirect user to this page the first time he logs in.
      data.sign_up_path = location.pathname
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
      {signupText, anonymous} = @props
      {basicData, studentData, teacherData} = @state
      (div {className: 'signup-form'},
        (div {className: 'title'}, if anonymous then 'Sign Up' else 'Finish Signing Up')
        (div {className: 'step'}, "Step #{@getStepNumber()} of 3")
        if studentData
          (StudentRegistrationComplete {anonymous, data: studentData})
        else if teacherData
          (TeacherRegistrationComplete {anonymous})
        else if !basicData
          (BasicDataForm {anonymous, signupText, onSubmit: @onBasicDataSubmit})
        else if basicData.type == 'student'
          (StudentForm {basicData, onRegistration: @onStudentRegistration})
        else if basicData.type == 'teacher'
          (TeacherForm {anonymous, basicData, onRegistration: @onTeacherRegistration})
      )

Portal.renderSignupForm = (selectorOrElement, properties = {}) ->
  Signup = React.createFactory modulejs.require('components/signup/signup')
  ReactDOM.render Signup(properties), jQuery(selectorOrElement)[0]
