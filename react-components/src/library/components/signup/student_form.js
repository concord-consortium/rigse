import React from 'react'
import TextInput, { asyncValidator } from './text_input'
import PrivacyPolicy from './privacy_policy'
import Formsy from 'formsy-react'

var INVALID_CLASS_WORD = 'You must enter a valid class word'

const classWordValidator = (value) => jQuery.get(Portal.API_V1.CLASSWORD + '?class_word=' + value)
const registerStudent = (params) => jQuery.post(Portal.API_V1.STUDENTS, params)

export default class StudentForm extends React.Component {
  constructor (props) {
    super(props)
    this.state = {
      canSubmit: false
    }
    this.onBasicFormValid = this.onBasicFormValid.bind(this)
    this.onBasicFormInvalid = this.onBasicFormInvalid.bind(this)
    this.submit = this.submit.bind(this)
  }

  onBasicFormValid () {
    this.setState({
      canSubmit: this.refs.classWord.isValidAsync()
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

    return registerStudent(params)
      .done(data => onRegistration(data))
      .fail(err => invalidateForm(JSON.parse(err.responseText).message))
  }

  render () {
    const validator = asyncValidator({
      validator: classWordValidator,
      error: INVALID_CLASS_WORD,
      ref: this.refs.classWord
    })
    return (
      <Formsy
        ref='form'
        onValidSubmit={this.submit}
        onValid={this.onBasicFormValid}
        onInvalid={this.onBasicFormInvalid}
      >
        <dl>
          <dt>Class Word</dt>
          <dd>
            <TextInput
              ref='classWord'
              name='class_word'
              placeholder='Class Word (not case sensitive)'
              required
              {...validator}
            />
          </dd>
        </dl>
        <PrivacyPolicy />
        <div className='submit-button-container'>
          <button className='submit-btn' type='submit' disabled={!this.state.canSubmit}>
            Register!
          </button>
        </div>
      </Formsy>
    )
  }
}
