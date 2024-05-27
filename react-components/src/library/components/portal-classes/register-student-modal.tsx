import React from 'react'

import ModalDialog from '../shared/modal-dialog'
import modalDialogCSS from '../shared/modal-dialog.scss'

export default class RegisterStudentModal extends React.Component<any, any> {
  firstNameRef: any;
  lastNameRef: any;
  passwordConfirmationRef: any;
  passwordRef: any;
  constructor (props: any) {
    super(props)
    this.handleCancel = this.handleCancel.bind(this)
    this.handleSubmit = this.handleSubmit.bind(this)

    this.firstNameRef = React.createRef()
    this.lastNameRef = React.createRef()
    this.passwordRef = React.createRef()
    this.passwordConfirmationRef = React.createRef()
  }

  getInputValue (ref: any) {
    return ref.current ? ref.current.value.trim() : ''
  }

  handleSubmit (e: any) {
    e.preventDefault()
    e.stopPropagation()

    const firstName = this.getInputValue(this.firstNameRef)
    const lastName = this.getInputValue(this.lastNameRef)
    const password = this.getInputValue(this.passwordRef)
    const passwordConfirmation = this.getInputValue(this.passwordConfirmationRef)

    if ((firstName.length === 0) || (lastName.length === 0) || (password.length === 0) || (passwordConfirmation.length === 0)) {
      return window.alert('Please fill in all the fields')
    }
    if (password !== passwordConfirmation) {
      return window.alert('Passwords do not match!')
    }

    this.props.onSubmit({ firstName, lastName, password, passwordConfirmation })
  }

  handleCancel () {
    this.props.onCancel()
  }

  render () {
    return (
      <ModalDialog title='Register & Add New Student'>
        <form onSubmit={this.handleSubmit}>
          <table>
            <tbody>
              <tr>
                <td><label htmlFor='firstName'>First Name</label></td>
                <td><input id='firstName' name='firstName' ref={this.firstNameRef} /></td>
              </tr>
              <tr>
                <td><label htmlFor='lastName'>Last Name</label></td>
                <td><input id='lastName' name='lastName' ref={this.lastNameRef} /></td>
              </tr>
              <tr>
                <td><label htmlFor='password'>Password</label></td>
                <td><input id='password' type='password' name='password' ref={this.passwordRef} /></td>
              </tr>
              <tr>
                <td><label htmlFor='passwordConfirmation'>Password Again</label></td>
                <td><input id='passwordConfirmation' type='password' name='passwordConfirmation' ref={this.passwordConfirmationRef} /></td>
              </tr>
              <tr>
                // @ts-expect-error TS(2322): Type 'string' is not assignable to type 'number'.
                <td colSpan={2} className={modalDialogCSS.buttons}>
                  <input type='submit' value='Submit' />
                  <button onClick={this.handleCancel}>Cancel</button>
                </td>
              </tr>
            </tbody>
          </table>
        </form>
      </ModalDialog>
    )
  }
}
