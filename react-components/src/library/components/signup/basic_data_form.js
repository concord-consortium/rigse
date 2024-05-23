import React from 'react'
import Formsy from 'formsy-react'
import TextInput from './text_input'

let INVALID_FIRST_NAME
let INVALID_LAST_NAME
let PASS_NOT_MATCH
let PASS_TOO_SHORT

PASS_TOO_SHORT = 'Password is too short'
PASS_NOT_MATCH = 'Passwords do not match'
INVALID_FIRST_NAME = 'Invalid first name. Use only letters and numbers.'
INVALID_LAST_NAME = 'Invalid last name. Use only letters and numbers.'

const enableAuthProviders = true

const nameValidator = (value) => jQuery.get(Portal.API_V1.NAME_VALID + '?name=' + value)

export default class BasicDataForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      canSubmit: false,
      password: ''
    }

    this.onChange = this.onChange.bind(this)
    this.onBasicFormValid = this.onBasicFormValid.bind(this)
    this.onBasicFormInvalid = this.onBasicFormInvalid.bind(this)
    this.submit = this.submit.bind(this)
  }

  onChange (model) {
    this.setState({
      password: model.password
    })
  }

  onBasicFormValid () {
    this.setState({
      canSubmit: true
    })
  }

  onBasicFormInvalid () {
    this.setState({
      canSubmit: false
    })
  }

  submit (model) {
    gtag('event', 'click', {
      'category': 'User Registration',
      'label': 'Form step 2 completed'
    })
    this.props.onSubmit(model)
  }

  render () {
    const anonymous = this.props.anonymous

    const providerComponents = []
    if (enableAuthProviders && this.props.oauthProviders) {
      const providers = this.props.oauthProviders
      providers.sort(function (a, b) { return (a.name > b.name) ? 1 : ((b.name > a.name) ? -1 : 0) }) // sort providers alphabetically by name
      for (let i = 0; i < providers.length; i++) {
        if (i === 0) {
          providerComponents.push(
            <p>Sign up with:</p>
          )
        }

        providerComponents.push(
          <a className='badge' id={providers[i].name} href={providers[i].directPath}>Sign up with {providers[i].display_name}</a>
        )
      }
      if (providers.length > 0) {
        providerComponents.push(
          //
          // Push separator bar
          //
          <div className='or-separator'>
            <span className='or-separator-text'>Or, create an account</span>
          </div>
        )
      }
    }

    return (
      <Formsy onValidSubmit={this.submit} onValid={this.onBasicFormValid} onInvalid={this.onBasicFormInvalid} onChange={this.onChange} role='form' aria-roledescription='form'>
        <div className='third-party-login-options testy' data-testid='third-party-login-options'>
          {providerComponents}
        </div>
        {
          anonymous &&
          <div>
            <dl>
              <dt className='two-col'>First Name</dt>
              <dd className='name_wrapper first-name-wrapper two-col'><TextInput name='first_name' placeholder='' required asyncValidation={nameValidator} asyncValidationError={INVALID_FIRST_NAME} /></dd>
              <dt className='two-col'>Last Name</dt>
              <dd className='name_wrapper last-name-wrapper two-col'><TextInput name='last_name' placeholder='' required asyncValidation={nameValidator} asyncValidationError={INVALID_LAST_NAME} /></dd>
              <dt>Password</dt>
              <dd><TextInput name='password' placeholder='' type='password' required validations={'minLength:6,maxLength:10'} validationError={PASS_TOO_SHORT} /></dd>
              <dt>Confirm Password</dt>
              <dd><TextInput name='password_confirmation' placeholder='' type='password' required validations={'equals:' + this.state.password} validationError={PASS_NOT_MATCH} /></dd>
            </dl>
          </div>
        }
        <div className='submit-button-container'>
          <button className='submit-btn' type='submit' disabled={!this.state.canSubmit}>{this.props.signupText}</button>
        </div>
      </Formsy>
    )
  }
}
