/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentRosterRow from 'components/portal-classes/student-roster-row'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a student roster row', () => {

  const student = {
    name: "Test Testerson",
    username: "tester",
    last_login: "Last Tuesday",
    assignments_started: 2,
    can_remove: false,
    can_reset_password: false
  }

  it("should render with default parameters", () => {
    const studentRosterRow = Enzyme.shallow(<StudentRosterRow student={student} />);
    expect(studentRosterRow.html()).toBe(pack(`
      <tr>
        <td>Test Testerson</td>
        <td>tester</td>
        <td>Last Tuesday</td>
        <td>2</td>
      </tr>
    `));
  });

  it("should render in edit mode with no permissions", () => {
    const studentRosterRow = Enzyme.shallow(<StudentRosterRow student={student} canEdit={true} />);
    expect(studentRosterRow.html()).toBe(pack(`
      <tr>
        <td>Test Testerson</td>
        <td>tester</td>
        <td>Last Tuesday</td>
        <td>2</td>
        <td class="hide_in_print"></td>
      </tr>
    `));
  });


  it("should render in edit mode with permissions", () => {
    const clonedStudent = JSON.parse(JSON.stringify(student))
    clonedStudent.can_remove = true
    clonedStudent.can_reset_password = true

    const removeStudent = jest.fn()
    const changePassword = jest.fn()

    const studentRosterRow = Enzyme.shallow(<StudentRosterRow student={clonedStudent} canEdit={true} onRemoveStudent={removeStudent} onChangePassword={changePassword} />);
    expect(studentRosterRow.html()).toBe(pack(`
      <tr>
        <td>Test Testerson</td>
        <td>tester</td>
        <td>Last Tuesday</td>
        <td>2</td>
        <td class="hide_in_print">
          <span class="link">Remove Student</span>
          <span class="link">Change Password</span>
        </td>
      </tr>
    `));

    expect(removeStudent).not.toHaveBeenCalled()
    expect(changePassword).not.toHaveBeenCalled()

    const removeStudentLink = studentRosterRow.find("span.link").at(0)
    const changePasswordLink = studentRosterRow.find("span.link").at(1)

    removeStudentLink.simulate("click")
    expect(removeStudent).toHaveBeenCalledWith(clonedStudent)
    expect(changePassword).not.toHaveBeenCalled()

    removeStudent.mockReset()

    changePasswordLink.simulate("click")
    expect(removeStudent).not.toHaveBeenCalled()
    expect(changePassword).toHaveBeenCalledWith(clonedStudent)
  });

})
