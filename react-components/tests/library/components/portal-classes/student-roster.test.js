/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentRoster from 'components/portal-classes/student-roster'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render a student roster', () => {

  const students = [
    {
      student_id: 1,
      name: "Student 1",
      username: "s1",
      last_login: "Last Tuesday",
      assignments_started: 1,
      can_remove: true,
      can_reset_password: true
    },
    {
      student_id: 2,
      name: "Student 2",
      username: "s2",
      last_login: "Never",
      assignments_started: 2,
      can_remove: true,
      can_reset_password: true
    }
  ];
  const otherStudents = [
    {
      id: 3,
      name: "Student 3",
      username: "s3"
    },
    {
      id: 4,
      name: "Student 4",
      username: "s4"
    }
  ];

  it("should render with default parameters", () => {
    const studentRoster = Enzyme.shallow(<StudentRoster canEdit={true} students={students} otherStudents={otherStudents} />);
    expect(studentRoster.html()).toBe(pack(`
      <div class="header">
        <div class="search">
          <div class="select">
            <select id="student_id_selector">
              <option selected="" value="0">Select registered student ...</option>
              <option value="3">Student 3 (s3)</option>
              <option value="4">Student 4 (s4)</option>
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
          <span class="link" role="link">Register &amp; Add New Student</span>
        </div>
      </div>
      <table class="table">
        <tbody>
          <tr>
            <th>Name</th>
            <th>Username</th>
            <th>Last Login</th>
            <th>Assignments Started</th>
            <th class="hide_in_print"></th>
          </tr>
          <tr>
            <td>Student 1</td>
            <td>s1</td>
            <td>Last Tuesday</td>
            <td>1</td>
            <td class="hide_in_print">
              <span class="link" role="link">Remove Student</span>
              <span class="link" role="link">Change Password</span>
            </td>
          </tr>
          <tr>
            <td>Student 2</td>
            <td>s2</td>
            <td>Never</td>
            <td>2</td>
            <td class="hide_in_print">
              <span class="link" role="link">Remove Student</span>
              <span class="link" role="link">Change Password</span>
            </td>
          </tr>
        </tbody>
      </table>
    `));
  });

  // NOTE: the header and the rows are tested fully in their own component tests

})
