/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import RegisterStudentModal from 'components/portal-classes/register-student-modal'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a register student modal', () => {

  it("should render", () => {
    const registerStudentModal = Enzyme.mount(<RegisterStudentModal />);
    expect(registerStudentModal.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div class="dialog">
          <div class="title">Register &amp; Add New Student</div>
          <form>
            <table>
              <tbody>
                <tr>
                  <td>
                    <label for="firstName">First Name</label>
                  </td>
                  <td>
                    <input name="firstName">
                  </td>
                </tr>
                <tr>
                  <td>
                    <label for="lastName">Last Name</label>
                  </td>
                  <td>
                    <input name="lastName">
                  </td>
                </tr>
                <tr>
                  <td>
                    <label for="password">Password</label>
                  </td>
                  <td>
                    <input type="password" name="password">
                  </td>
                </tr>
                <tr>
                  <td>
                    <label for="passwordConfirmation">Password Again</label>
                  </td>
                  <td>
                    <input type="password" name="passwordConfirmation">
                  </td>
                </tr>
                <tr>
                  <td colspan="2" class="buttons">
                    <input type="submit" value="Submit">
                    <button>Cancel</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </form>
        </div>
      </div>
    `));
  });

  it("should support the cancel button", () => {
    const cancel = jest.fn()
    const registerStudentModal = Enzyme.mount(<RegisterStudentModal onCancel={cancel} />);
    const cancelButton = registerStudentModal.find("button").first()
    cancelButton.simulate("click")
    expect(cancel).toHaveBeenCalled()
  })

  it("should not submit without the fields being filled", () => {
    const savedAlert = global.alert
    global.alert = jest.fn()

    const submit = jest.fn()
    const registerStudentModal = Enzyme.mount(<RegisterStudentModal onSubmit={submit} />);
    const form = registerStudentModal.find("form").first()
    form.prop("onSubmit")({preventDefault: () => undefined, stopPropagation: () => undefined})

    expect(global.alert).toHaveBeenCalledWith("Please fill in all the fields")
    expect(submit).not.toHaveBeenCalled()

    global.alert = savedAlert
  })

  it("should not submit without the passwords matching", () => {
    const savedAlert = global.alert
    global.alert = jest.fn()

    const submit = jest.fn()
    const registerStudentModal = Enzyme.mount(<RegisterStudentModal onSubmit={submit} />);
    const form = registerStudentModal.find("form").first()
    const firstNameInput = registerStudentModal.find("input[name='firstName']").first()
    const lastNameInput = registerStudentModal.find("input[name='lastName']").first()
    const passwordInput = registerStudentModal.find("input[name='password']").first()
    const passwordConfirmationInput = registerStudentModal.find("input[name='passwordConfirmation']").first()
    const submitForm = () => form.prop("onSubmit")({preventDefault: () => undefined, stopPropagation: () => undefined})

    firstNameInput.instance().value = "Test"
    lastNameInput.instance().value = "Testerson"
    passwordInput.instance().value = "passw0rd"
    passwordConfirmationInput.instance().value = "not same password"

    submitForm()

    expect(global.alert).toHaveBeenCalledWith("Passwords do not match!")
    expect(submit).not.toHaveBeenCalled()

    global.alert.mockReset()
    passwordConfirmationInput.instance().value = "passw0rd"

    submitForm()

    expect(global.alert).not.toHaveBeenCalledWith("Passwords do not match!")
    expect(submit).toHaveBeenCalledWith({
      firstName: "Test",
      lastName: "Testerson",
      password: "passw0rd",
      passwordConfirmation: "passw0rd"
    })

    global.alert = savedAlert
  })

})
