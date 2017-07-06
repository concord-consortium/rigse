{div} = React.DOM

modulejs.define 'components/signup/signup',
[
  'components/signup/basic_data_form',
  'components/signup/sideinfo',
  'components/signup/student_form',
  'components/signup/student_form_sideinfo',
  'components/signup/teacher_form',
  'components/signup/student_registration_complete',
  'components/signup/student_registration_complete_sideinfo',
  'components/signup/teacher_registration_complete'
],
(
  BasicDataFormClass,
  SideInfoClass,
  StudentFormClass,
  StudentFormSideInfoClass,
  TeacherFormClass,
  StudentRegistrationCompleteClass,
  StudentRegistrationCompleteSideInfoClass,
  TeacherRegistrationCompleteClass
) ->
  BasicDataForm = React.createFactory BasicDataFormClass
  SideInfo = React.createFactory SideInfoClass
  StudentForm = React.createFactory StudentFormClass
  StudentFormSideInfo = React.createFactory StudentFormSideInfoClass
  TeacherForm = React.createFactory TeacherFormClass
  StudentRegistrationComplete = React.createFactory StudentRegistrationCompleteClass
  StudentRegistrationCompleteSideInfo = React.createFactory StudentRegistrationCompleteSideInfoClass
  TeacherRegistrationComplete = React.createFactory TeacherRegistrationCompleteClass

  React.createClass
    displayName: 'SignUp'
    getInitialState: ->
      basicData: null
      studentData: null
      teacherData: null

    getDefaultProps: ->
      signupText:   "Sign Up for #{Portal.siteName}!"
      signupGoogle: "Sign Up with Google"
      # When user is anonymous, we need to ask about all the information (email, login, password).
      # However, sometimes users are using SSO and basic user object can be already created. Then we only
      # need to create Portal-specific models (student or teacher).
      # Note: if the user loaded the page while they were anonymous, but then logged in in another
      # tab, this property will be incorrect
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
      {signupText, signupGoogle, anonymous} = @props
      {basicData, studentData, teacherData} = @state
      (div {},
        (div {className: 'title'}, if anonymous then 'Sign Up' else 'Finish Signing Up')
        (div {className: 'step'}, "Step #{@getStepNumber()} of 3")
        (div {className: 'signup-form'},
          if studentData
            (StudentRegistrationComplete {anonymous, data: studentData})
          else if teacherData
            (TeacherRegistrationComplete {anonymous})
          else if !basicData
            (BasicDataForm {anonymous, signupText, signupGoogle, onSubmit: @onBasicDataSubmit})
          else if basicData.type == 'student'
            (StudentForm {basicData, onRegistration: @onStudentRegistration})
          else if basicData.type == 'teacher'
            (TeacherForm {anonymous, basicData, onRegistration: @onTeacherRegistration})
        ),
        (div {className: 'side-info'},
          if studentData
            # StudentRegistrationCompleteSideInfo contains a login form
            # If the student is already logged in because of the SSO path, don't show
            # this form or anything else in the side info section.
            if anonymous
              (StudentRegistrationCompleteSideInfo {})
          else if !basicData
            (SideInfo {})
          else if basicData.type == 'student'
            (StudentFormSideInfo {})
          else
            (SideInfo {})
        )
      )

Portal.renderSignupForm = (selectorOrElement, properties = {}) ->
  Signup = React.createFactory modulejs.require('components/signup/signup')
  ReactDOM.render Signup(properties), jQuery(selectorOrElement)[0]
