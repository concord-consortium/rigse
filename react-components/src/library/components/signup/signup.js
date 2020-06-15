import React from 'react'

import StudentForm from './student_form'
import TeacherForm from './teacher_form'
import BasicDataForm from './basic_data_form'
import StudentRegistrationComplete from './student_registration_complete'
import TeacherRegistrationComplete from './teacher_registration_complete'
import UserTypeSelector from './user_type_selector'

import ParseQueryString from '../../helpers/parse-query-string'

export default class SignUp extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      userType: null,
      basicData: null,
      studentData: null,
      teacherData: null,
      oauthProviders: this.props.oauthProviders,
      closeable: this.props.closeable
    }

    this.onUserTypeSelect = this.onUserTypeSelect.bind(this)
    this.onBasicDataSubmit = this.onBasicDataSubmit.bind(this)
    this.onStudentRegistration = this.onStudentRegistration.bind(this)
    this.onTeacherRegistration = this.onTeacherRegistration.bind(this)
  }

  onUserTypeSelect (data) {
    let newUrl = window.location.protocol + '//' + window.location.host + window.location.pathname
    let queryString = '?'

    if (window.location.search) {
      let params = ParseQueryString()
      let paramKeys = Object.keys(params)
      for (let i = 0; i < paramKeys.length; i++) {
        if (paramKeys[i] !== 'userType') {
          queryString = queryString + paramKeys[i] + '=' + params[paramKeys[i]] + '&'
        }
      }
    }
    queryString = queryString + 'userType=' + data
    newUrl = newUrl + queryString

    window.history.pushState({ path: newUrl }, '', newUrl)
    this.setState({
      userType: data
    })
  }

  onBasicDataSubmit (data) {
    data.sign_up_path = window.location.pathname
    this.setState({
      basicData: data
    })
  }

  onStudentRegistration (data) {
    this.setState({
      studentData: data
    })
  }

  onTeacherRegistration (data) {
    this.setState({
      teacherData: data
    })
  }

  getStepNumber () {
    const { basicData, studentData, teacherData } = this.state

    // console.log("INFO getStepNumber", this.props, basicData);

    if (!this.props.omniauth && !basicData) {
      return 1
    }
    if (this.props.omniauth || (basicData && !studentData && !teacherData)) {
      return 2
    }
    return 3
  }

  render () {
    console.log('INFO rendering signup', this.props)

    const { signupText, oauthProviders, anonymous, omniauthOrigin } = this.props
    const { userType, basicData, studentData, teacherData } = this.state

    let form

    //
    // For omniauth final step, simply redirect to omniauth_origin
    //
    if ((studentData || teacherData) && this.props.omniauth) {
      console.log('INFO omniauth final step, redirect.', this.props)
      let data = this.state.studentData ? this.state.studentData : this.state.teacherData
      window.location.href = data.omniauth_origin
      return null
    }

    if (studentData) {
      //
      // Display completion step
      //
      form = <StudentRegistrationComplete anonymous={anonymous} data={studentData} />
    } else if (teacherData) {
      //
      // Display completion step
      //
      form = <TeacherRegistrationComplete anonymous={anonymous} />
    } else if (omniauthOrigin != null) {
      if (omniauthOrigin.search('teacher') > -1) {
        form = <TeacherForm
          anonymous={this.props.anonymous}
          basicData={basicData}
          onRegistration={this.onTeacherRegistration}
        />
      } else if (omniauthOrigin.search('student') > -1) {
        form = <StudentForm
          basicData={basicData}
          onRegistration={this.onStudentRegistration}
        />
      }
    } else if (!userType) {
      // console.log("INFO signup form creating type selector step");

      // studentReg: this.onStudentRegistration,
      // teacherReg: this.onTeacherRegistration,
      form = <UserTypeSelector
        anonymous={anonymous}
        onUserTypeSelect={this.onUserTypeSelect}
      />
    } else if (basicData) {
      if (userType === 'teacher') {
        form = <TeacherForm
          anonymous={this.props.anonymous}
          basicData={basicData}
          onRegistration={this.onTeacherRegistration}
        />
      } else {
        form = <StudentForm
          basicData={basicData}
          onRegistration={this.onStudentRegistration}
        />
      }
    } else {
      // console.log("INFO signup form creating basic data selector step");
      form = <BasicDataForm
        anonymous={anonymous}
        userType={userType}
        signupText={signupText}
        oauthProviders={oauthProviders}
        onSubmit={this.onBasicDataSubmit}
      />
    }

    let formTitleIntro = 'Register'
    if (this.state.userType != null) {
      formTitleIntro = 'Register as a ' + userType.charAt(0).toUpperCase() + userType.slice(1)
    }

    let formTitle = anonymous ? <h2><strong>{formTitleIntro}</strong> for the {this.props.siteName}</h2> : <h2><strong>Finish</strong> Signing Up</h2>

    return (
      <div>
        {formTitle}
        <div className='signup-form'>
          {form}
        </div>
        <footer className='reg-footer'>
          <p><strong>Why sign up?</strong> It's free and you get access to several key features, like creating classes for your students, assigning activities, saving work, tracking student progress, and more!</p>
        </footer>
      </div>
    )
  }
}

SignUp.defaultProps = {
  siteName: (window.Portal && window.Portal.siteName) || 'Portal',
  signupText: 'Next',
  anonymous: window.Portal && window.Portal.currentUser.isAnonymous
}
