import React from 'react'
import Formsy from 'formsy-react'

import TextInput, { asyncValidator } from './text_input'
import CheckboxInput from './checkbox_input'
import SelectInput from './select_input'
import SchoolInput from './school_input'
import PrivacyPolicy from './privacy_policy'

const LOGIN_TOO_SHORT = 'Login is too short'
const LOGIN_INVALID = 'Invalid login. This name is either already taken or does not use only letters, numbers and the characters .+-_@'
const EMAIL_REGEXP = 'Email doesn\'t appear to be a valid email'
const EMAIL_TAKEN = 'Email belongs to an existing user'
const CANT_FIND_SCHOOL = 'I can\'t find my school in the list.'
const GO_BACK_TO_LIST = 'Go back to the school list.'

const newSchoolWarning = (zipOrPostal) => `You are adding a new school / institution. Please make sure that the ${zipOrPostal} and school / institution name are correct!`
const invalidZipcode = (zipOrPostal) => `Incorrect ${zipOrPostal}`

const loginValidValidator = (value) => jQuery.get(Portal.API_V1.LOGIN_VALID + '?username=' + value)
const emailAvailableValidator = (value) => jQuery.get(Portal.API_V1.EMAILS + '?email=' + value)
const getCountries = () => jQuery.get(Portal.API_V1.COUNTRIES)
const registerTeacher = (params) => jQuery.post(Portal.API_V1.TEACHERS, params)
const isUS = (name) => name === 'United States' || name === 'US' || name === 'USA'

export default class TeacherForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      canSubmit: false,
      currentCountry: null,
      currentZipcode: null,
      isUSSelected: false,
      registerNewSchool: false,
      showZipcodeHelp: false
    }

    this.onBasicFormValid = this.onBasicFormValid.bind(this)
    this.onBasicFormInvalid = this.onBasicFormInvalid.bind(this)
    this.submit = this.submit.bind(this)
    this.onChange = this.onChange.bind(this)
    this.getCountries = this.getCountries.bind(this)
    this.addNewSchool = this.addNewSchool.bind(this)
    this.goBackToSchoolList = this.goBackToSchoolList.bind(this)
    this.showZipcodeHelp = this.showZipcodeHelp.bind(this)
    this.checkIfUS = this.checkIfUS.bind(this)
    this.zipcodeValidation = this.zipcodeValidation.bind(this)
    this.zipOrPostal = this.zipOrPostal.bind(this)
  }

  onBasicFormValid () {
    let valid = true
    if (this.refs.login && !this.refs.login.isValidAsync()) {
      valid = false
    }
    if (this.refs.email && !this.refs.email.isValidAsync()) {
      valid = false
    }
    this.setState({
      canSubmit: valid
    })
  }

  onBasicFormInvalid () {
    this.setState({
      canSubmit: false
    })
  }

  submit (data, resetForm, invalidateForm) {
    const { basicData, onRegistration } = this.props
    const params = jQuery.extend({}, basicData, data)
    this.setState({
      canSubmit: false
    })

    return registerTeacher(params)
      .done(data => {
        console.log('INFO Registered teacher.', data)
        return onRegistration(data)
      })
      .fail(err => {
        return invalidateForm(JSON.parse(err.responseText).message)
      })
  }

  onChange (currentValues) {
    const countryId = currentValues.country_id
    const zipcode = currentValues.zipcode
    const { currentZipcode, registerNewSchool } = this.state
    const zipcodeValid = this.refs.zipcode && this.refs.zipcode.isValidValue(zipcode)

    this.setState({
      currentCountry: countryId,
      currentZipcode: (zipcodeValid && zipcode) || null,
      registerNewSchool: registerNewSchool && zipcode === currentZipcode
    })
  }

  getCountries (input, callback) {
    getCountries().done(data => {
      callback(null, {
        options: data.map(function (country) {
          return {
            label: country.name,
            value: country.id
          }
        }),
        complete: true
      })
    })
  }

  addNewSchool () {
    this.setState({
      registerNewSchool: true
    })
  }

  goBackToSchoolList () {
    this.setState({
      registerNewSchool: false
    })
  }

  showZipcodeHelp () {
    this.setState({
      showZipcodeHelp: true
    })
  }

  checkIfUS (option) {
    this.setState({
      isUSSelected: isUS(option.label)
    })
  }

  zipcodeValidation (values, value) {
    if (!this.state.isUSSelected) {
      return true
    }
    return value && value.match(/\d{5}/)
  }

  zipOrPostal () {
    if (this.state.isUSSelected) {
      return 'ZIP code'
    } else {
      return 'postal code'
    }
  }

  renderAnonymous (showEnewsSubscription) {
    const loginValidator = asyncValidator({
      validator: loginValidValidator,
      error: LOGIN_INVALID,
      ref: this.refs.login
    })
    const emailValidator = asyncValidator({
      validator: emailAvailableValidator,
      error: EMAIL_TAKEN,
      ref: this.refs.email
    })
    return (
      <div>
        <dl>
          <dt>Username</dt>
          <dd>
            <TextInput
              ref='login'
              name='login'
              placeholder=''
              // eslint-disable-next-line
              required={true}
              validations={{
                minLength: 3
              }}
              validationErrors={{
                minLength: LOGIN_TOO_SHORT
              }}
              {...loginValidator}
            />
          </dd>
          <dt>Email</dt>
          <dd>
            <TextInput
              ref='email'
              name='email'
              placeholder=''
              // eslint-disable-next-line
              required={true}
              validations={{
                isEmail: true
              }}
              validationErrors={{
                isEmail: EMAIL_REGEXP
              }}
              {...emailValidator}
            />
          </dd>
          {showEnewsSubscription
            ? <dd>
              <CheckboxInput
                ref='email_subscribed'
                name='email_subscribed'
                required={false}
                defaultChecked='true'
                label='Send me updates about educational technology resources.'
              />
            </dd> : undefined}
        </dl>
      </div>
    )
  }

  renderZipcode () {
    return (
      <dl>
        <dt>ZIP Code</dt>
        <dd>
          <div>
            <TextInput
              ref='zipcode'
              name='zipcode'
              placeholder={'School / Institution ' + (this.zipOrPostal())}
              // eslint-disable-next-line
              required={true}
              validations={{
                zipcode: this.zipcodeValidation
              }}
              validationErrors={{
                zipcode: invalidZipcode(this.zipOrPostal())
              }}
              processValue={(val) => val.replace(/\s/g, '')}
            />
          </div>
        </dd>
      </dl>
    )
  }

  render () {
    const { anonymous } = this.props
    const { canSubmit, currentCountry, currentZipcode, registerNewSchool } = this.state
    const showZipcode = currentCountry != null
    const showSchool = (currentCountry != null) && (currentZipcode != null)
    const showEnewsSubscription = !!Portal.enewsSubscriptionEnabled

    return (
      <Formsy
        ref='form'
        onValidSubmit={this.submit}
        onValid={this.onBasicFormValid}
        onInvalid={this.onBasicFormInvalid}
        onChange={this.onChange}
      >
        {anonymous ? this.renderAnonymous(showEnewsSubscription) : undefined}
        <dl>
          <dt>Country</dt>
          <dd>
            <SelectInput
              name='country_id'
              placeholder=''
              loadOptions={this.getCountries}
              required
              onChange={this.checkIfUS}
            />
          </dd>
        </dl>
        {showZipcode ? this.renderZipcode() : undefined}
        <dl>
          {showSchool && !registerNewSchool
            ? <dt>School</dt>
            : undefined}
          {showSchool && !registerNewSchool
            ? <dd className='signup-form-school-select'>
              <SchoolInput
                name='school_id'
                placeholder='School / Institution'
                country={currentCountry}
                zipcode={currentZipcode}
                onAddNewSchool={this.addNewSchool}
                required
              />
            </dd> : undefined}
          <dd>
            {showSchool && !registerNewSchool
              ? <a className='signup-form-add-school-link' onClick={this.addNewSchool}>{CANT_FIND_SCHOOL}</a>
              : undefined}
            {showSchool && registerNewSchool
              ? <div>
                <TextInput
                  name='school_name'
                  placeholder='School / Institution Name'
                  required
                />
                <div className='help-text'>
                  {newSchoolWarning(this.zipOrPostal())}
                </div>
              </div>
              : undefined}
            {showSchool && registerNewSchool
              ? <a onClick={this.goBackToSchoolList}>{GO_BACK_TO_LIST}</a>
              : undefined}
          </dd>
        </dl>
        {!anonymous && showEnewsSubscription
          ? <div className='signup-form-enews-optin-standalone'>
            <CheckboxInput
              ref='email_subscribed'
              name='email_subscribed'
              required={false}
              defaultChecked
              label='Send me updates about educational technology resources.'
            />
          </div>
          : undefined}
        <PrivacyPolicy />
        <div className='submit-button-container'>
          <button className='submit-btn' type='submit' disabled={!canSubmit}>Register!</button>
        </div>
      </Formsy>
    )
  }
}
