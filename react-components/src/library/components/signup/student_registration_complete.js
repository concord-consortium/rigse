import React from 'react'
import Formsy from 'formsy-react'
import TextInput from './text_input'

export default class StudentRegistrationComplete extends React.Component {
  constructor (props) {
    super(props)
    this.submit = this.submit.bind(this)
  }

  componentDidMount () {
    ga('send', 'event', 'User Registration', 'Form', 'Final Step Completed - Student')
  }

  submit (data) {
    if (this.props.afterSigninPath) {
      data.after_sign_in_path = this.props.afterSigninPath
    }

    jQuery.post('/api/v1/users/sign_in', data).done(function (response) {
      console.log('INFO login success', response)
      if (response.redirect_path) {
        window.location = response.redirect_path
      } else {
        window.location.reload(true)
      }
    }).fail(function (err) {
      console.log('INFO login error', err)
      console.log('INFO login error responseText', err.responseText)
      let response = jQuery.parseJSON(err.responseText)
      //
      // TODO use some kind of styled modal dialog here.....
      //
      window.alert('Error: ' + response.message)
    })
  }

  render () {
    const { anonymous, data } = this.props
    const { login } = data

    const successMessage = anonymous ? <div><p style={{ marginBottom: '30px' }}>Success! Your username is <span className='login'>{login}</span></p><p style={{ marginBottom: '30px' }}>Use your new account to sign in below.</p></div> : <p><a href='/'>Start using the site.</a></p>

    return (
      <div className='registration-complete student'>
        {successMessage}
        <Formsy className='signup-form' onValidSubmit={this.submit}>
          <dl>
            <dt>Username</dt>
            <dd>
              <TextInput name='user[login]' placeholder='' required />
            </dd>
            <dt>Password</dt>
            <dd>
              <TextInput name='user[password]' placeholder='' type='password' required />
            </dd>
          </dl>
          <div className='submit-button-container'>
            <button className='submit-btn' type='submit'>Log In!</button>
          </div>
        </Formsy>
      </div>
    )
  }
}
