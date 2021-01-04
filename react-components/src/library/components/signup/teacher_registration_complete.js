import React from 'react'

export default class TeacherRegistrationComplete extends React.Component {
  componentDidMount () {
    ga('send', 'event', 'User Registration', 'Form', 'Final Step Completed - Teacher')
  }

  render () {
    let successMessage = this.props.anonymous
      ? <p>We're sending you an email with your activation code. Click the "Confirm Account" link in the email to complete the process.</p>
      : <p><a href='/'>Start using the site.</a></p>

    return (
      <div className='registration-complete'>
        <p className='reg-header'>Thanks for signing up!</p>
        {successMessage}
      </div>
    )
  }
}
