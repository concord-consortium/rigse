/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentRosterHeader from 'components/portal-classes/student-roster-header'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a student roster header', () => {

  it("should render with default parameters", () => {
    const studentRosterHeader = Enzyme.mount(<StudentRosterHeader />);
    expect(studentRosterHeader.html()).toBe(pack(`
      <div class="header">
        <div class="search">
          Please register students or have them self-register with the class word in order to add them to this class
        </div>
        <div class="or">
          or
        </div>
        <div>
          <span class="link" role="link">
            Register &amp; Add New Student
          </span>
        </div>
      </div>
    `));
  });

  const otherStudents = [
    {id: 1, name: "Student 1", username: "s1"},
    {id: 2, name: "Student 2", username: "s2"},
    {id: 3, name: "Student 3", username: "s3"}
  ]

  it("should render with students", () => {
    const studentRosterHeader = Enzyme.mount(<StudentRosterHeader otherStudents={otherStudents} />);
    expect(studentRosterHeader.html()).toBe(pack(`
      <div class="header">
        <div class="search">
          <div class="select">
            <select id="student_id_selector">
              <option value="0">Select registered student ...</option>
              <option value="1">Student 1 (s1)</option>
              <option value="2">Student 2 (s2)</option>
              <option value="3">Student 3 (s3)</option>
            </select>
          </div>
          <div>
            <button disabled="">Add</button>
          </div>
        </div>
        <div class="or">
          or
        </div>
        <div>
          <span class="link" role="link">
            Register &amp; Add New Student
          </span>
        </div>
      </div>
    `));
  });

  it("should enable and disable the add button", () => {
    const addStudent = jest.fn()
    const studentRosterHeader = Enzyme.mount(<StudentRosterHeader otherStudents={otherStudents} onAddStudent={addStudent} />);
    expect(studentRosterHeader.html()).toContain('<button disabled="">Add</button>')

    const select = studentRosterHeader.find("select").first()
    const addButton = studentRosterHeader.find("button").first()

    addButton.simulate("click")
    expect(addStudent).not.toHaveBeenCalled()

    select.prop("onChange")({ target: { value: "1" }})
    expect(studentRosterHeader.html()).not.toContain('<button disabled="">Add</button>')
    expect(studentRosterHeader.html()).toContain('<button>Add</button>')

    addStudent.mockReset()
    addButton.simulate("click")
    expect(addStudent).toHaveBeenCalledWith(otherStudents[0])

    select.prop("onChange")({ target: { value: "" }})
    expect(studentRosterHeader.html()).toContain('<button disabled="">Add</button>')
    expect(studentRosterHeader.html()).not.toContain('<button>Add</button>')

    addStudent.mockReset()
    addButton.simulate("click")
    expect(addStudent).not.toHaveBeenCalled()
  });

  it("should handle the register & add new student action", () => {
    const registerStudent = jest.fn()
    const studentRosterHeader = Enzyme.mount(<StudentRosterHeader onRegisterStudent={registerStudent} />);
    expect(studentRosterHeader.html()).toContain('<span class="link" role="link">Register &amp; Add New Student</span>')

    expect(registerStudent).not.toHaveBeenCalled()

    const register = studentRosterHeader.find("span.link").first()
    register.simulate("click")
    expect(registerStudent).toHaveBeenCalled()
  })

  it("should render with students with allowDefaultClass", () => {
    const studentRosterHeader = Enzyme.mount(<StudentRosterHeader otherStudents={otherStudents} allowDefaultClass={true} />);
    expect(studentRosterHeader.html()).toBe(pack(`
      <div class="header">
        <div class="search">
          If a student already has an account, ask the student to enter the Class Word above
        </div>
        <div class="or">
          or
        </div>
        <div>
          <span class="link" role="link">
            Register &amp; Add New Student
          </span>
        </div>
      </div>
    `));
  });


})
