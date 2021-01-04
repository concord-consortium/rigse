/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import ClassSetupForm from 'components/portal-classes/setup-form'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render class setup form', () => {

  const createProps = {
    portalClass: {teacher_id: 2},
    portalClassGrades: [],
    portalClassTeacher: {name: "Joe Tester", id: 1},
    teachers: {
      current: [{name: "Tester, J. (joetester)", id: 1}],
      unassigned: [],
    },
    errors: {},
    schools: [{id: 1, name: "Example School"}],
    enableGradeLevels: true,
    activeGrades: ["1","2","3","4","5","6","7","8","9","10","11","12","Higher Ed"],
    cancelLink: "https://example.com/home"
  }

  const editProps = {
    portalClass: {
      id: 5,
      teacher_id: 2,
      class_word: "testclass",
      name: "Test Class",
      description: "This is the test class"
    },
    portalClassGrades: ["1","5","9"],
    portalClassTeacher: {name: "Joe Tester", id: 1},
    teachers: {
      current: [{name: "Tester, J. (joetester)", id: 1}],
      unassigned: [
        {name: "Bobberton, B. (bob)", id: 2},
        {name: "Bar, F. (foobar)", id: 3},
        {name: "Bang, B. (bazbang)", id: 4}],
    },
    errors: {},
    schools: [],
    enableGradeLevels: true,
    activeGrades: ["1","2","3","4","5","6","7","8","9","10","11","12","Higher Ed"],
    cancelLink: "https://example.com/home"
  }

  it("should render in create mode", () => {
    const classSetupForm = Enzyme.mount(<ClassSetupForm {...createProps} />);
    expect(classSetupForm.html()).toBe(pack(`
      <div class="content"></div>
      <div class="right">
        <h1>Class Setup Information</h1>
        <table class="classsetupform">
          <tbody>
            <tr>
              <td class="title">
                <label class="right" for="name" style="white-space: nowrap;">Class Name:</label>
              </td>
              <td>
                <input id="portal_clazz_name" name="portal_clazz[name]" size="30" type="text" value="">
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="description" style="white-space: nowrap;">Description:</label>
              </td>
              <td>
                <textarea class="mceNoEditor" id="portal_clazz_description" name="portal_clazz[description]" rows="5" cols="50"></textarea>
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="class_word" style="white-space: nowrap;">Class Word:</label>
              </td>
              <td>
                <input id="portal_clazz_class_word" name="portal_clazz[class_word]" type="text" value="">
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="school" style="white-space: nowrap;">School:</label>
              </td>
              <td>
                <select id="portal_clazz_school" name="portal_clazz[school]">
                  <option value="1">Example School</option>
                </select>
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="grade_levels" style="white-space: nowrap;">Grade Levels:</label>
              </td>
              <td>
                <table style="width: 100%;">
                  <tbody>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][1]" value="1"> <label for="portal_clazz[grade_levels][1]">1</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][2]" value="1"> <label for="portal_clazz[grade_levels][2]">2</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][3]" value="1"> <label for="portal_clazz[grade_levels][3]">3</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][4]" value="1"> <label for="portal_clazz[grade_levels][4]">4</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][5]" value="1"> <label for="portal_clazz[grade_levels][5]">5</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][6]" value="1"> <label for="portal_clazz[grade_levels][6]">6</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][7]" value="1"> <label for="portal_clazz[grade_levels][7]">7</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][8]" value="1"> <label for="portal_clazz[grade_levels][8]">8</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][9]" value="1"> <label for="portal_clazz[grade_levels][9]">9</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][10]" value="1"> <label for="portal_clazz[grade_levels][10]">10</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][11]" value="1"> <label for="portal_clazz[grade_levels][11]">11</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][12]" value="1"> <label for="portal_clazz[grade_levels][12]">12</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][Higher Ed]" value="1"> <label for="portal_clazz[grade_levels][Higher Ed]">Higher Ed</label>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>
          </tbody>
        </table>
        <hr class="ht-thick">
        <div class="form-submit">
          <a href="https://example.com/home">Cancel</a>
          <span class="create_button">
            <input type="submit" class="pie" value="Save Changes"></span>
        </div>
      </div>
      <input type="hidden" name="teacher_id" value="2">
    `));
  });

  it("should render in edit mode", () => {
    const classSetupForm = Enzyme.mount(<ClassSetupForm {...editProps} />);
    expect(classSetupForm.html()).toBe(pack(`
      <div class="content"></div>
      <div class="right">
        <h1>Class Setup Information</h1>
        <dl class="classdata">
          <dt>Teacher:</dt>
          <dd> Joe Tester</dd>
          <dt>Class Word:</dt>
          <dd> testclass</dd>
        </dl>
        <table class="classsetupform">
          <tbody>
            <tr>
              <td class="title">
                <label class="right" for="name" style="white-space: nowrap;">Class Name:</label>
              </td>
              <td>
                <input id="portal_clazz_name" name="portal_clazz[name]" size="30" type="text" value="Test Class">
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="teachers" style="white-space: nowrap;">Teachers:</label>
              </td>
              <td class="left">
                <div class="class-teachers">
                  <span class="nobreak" id="teacher_add_dropdown">
                    <select id="teacher_id_selector">
                      <option value="2">Bobberton, B. (bob)</option>
                      <option value="3">Bar, F. (foobar)</option>
                      <option value="4">Bang, B. (bazbang)</option>
                    </select>
                    <input type="button" value="Add">
                  </span>
                  <div id="div_teacher_list">
                    <ul>
                      <li>
                        Tester, J. (joetester) <span><img class="deleteDisabledIcon" alt="You cannot remove the last teacher from this class." src="data:image/svg+xml,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot;/>" title="You cannot remove the last teacher from this class."></span>
                      </li>
                    </ul>
                  </div>
                </div>
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="description" style="white-space: nowrap;">Description:</label>
              </td>
              <td>
                <textarea class="mceNoEditor" id="portal_clazz_description" name="portal_clazz[description]" rows="5" cols="50">This is the test class</textarea>
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="class_word" style="white-space: nowrap;">Class Word:</label>
              </td>
              <td>
                <input id="portal_clazz_class_word" name="portal_clazz[class_word]" type="text" value="testclass">
              </td>
            </tr>
            <tr>
              <td class="title">
                <label class="right" for="grade_levels" style="white-space: nowrap;">Grade Levels:</label>
              </td>
              <td>
                <table style="width: 100%;">
                  <tbody>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][1]" value="1" checked=""> <label for="portal_clazz[grade_levels][1]">1</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][2]" value="1"> <label for="portal_clazz[grade_levels][2]">2</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][3]" value="1"> <label for="portal_clazz[grade_levels][3]">3</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][4]" value="1"> <label for="portal_clazz[grade_levels][4]">4</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][5]" value="1" checked=""> <label for="portal_clazz[grade_levels][5]">5</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][6]" value="1"> <label for="portal_clazz[grade_levels][6]">6</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][7]" value="1"> <label for="portal_clazz[grade_levels][7]">7</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][8]" value="1"> <label for="portal_clazz[grade_levels][8]">8</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][9]" value="1" checked=""> <label for="portal_clazz[grade_levels][9]">9</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][10]" value="1"> <label for="portal_clazz[grade_levels][10]">10</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][11]" value="1"> <label for="portal_clazz[grade_levels][11]">11</label>
                      </td>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][12]" value="1"> <label for="portal_clazz[grade_levels][12]">12</label>
                      </td>
                    </tr>
                    <tr>
                      <td style="text-align: left; white-space: nowrap; width: 23.75%;">
                        <input type="checkbox" name="portal_clazz[grade_levels][Higher Ed]" value="1"> <label for="portal_clazz[grade_levels][Higher Ed]">Higher Ed</label>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </td>
            </tr>
          </tbody>
        </table>
        <hr class="ht-thick">
        <div class="form-submit">
          <a href="https://example.com/home">Cancel</a>
          <span class="create_button">
            <input type="submit" class="pie" value="Save Changes">
          </span>
        </div>
      </div>
      <input type="hidden" name="teacher_id" value="2">
      <input type="hidden" name="id" value="5">
      <input type="hidden" name="portal_clazz[current_teachers]" value="1">
    `));
  });

  it("should allow adding and removing teachers", () => {
    const classSetupForm = Enzyme.mount(<ClassSetupForm {...editProps} />);
    const addButton = classSetupForm.find('span[id="teacher_add_dropdown"]').find('input[type="button"]');
    const teacherList = classSetupForm.find('#div_teacher_list');

    const beforeAddHTML = pack(`
      <div id="div_teacher_list">
        <ul>
          <li>
            Tester, J. (joetester) <span><img class="deleteDisabledIcon" alt="You cannot remove the last teacher from this class." src="data:image/svg+xml,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot;/>" title="You cannot remove the last teacher from this class."></span>
          </li>
        </ul>
      </div>
    `)
    const afterAddHTML = pack(`
      <div id="div_teacher_list">
        <ul>
          <li>
            Bobberton, B. (bob) <span><img class="deleteIcon" alt="Remove Bobberton, B. (bob) from class" src="data:image/svg+xml,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot;/>" title="Remove Bobberton, B. (bob) from class"></span>
          </li>
          <li>
            Tester, J. (joetester) <span><img class="deleteIcon" alt="Remove Tester, J. (joetester) from class" src="data:image/svg+xml,<svg xmlns=&quot;http://www.w3.org/2000/svg&quot;/>" title="Remove Tester, J. (joetester) from class"></span>
          </li>
        </ul>
      </div>
    `)

    expect(teacherList.html()).toBe(beforeAddHTML);
    addButton.simulate("click");
    classSetupForm.update();
    expect(teacherList.html()).toBe(afterAddHTML);

    const firstRemoveButton = classSetupForm.find('img.deleteIcon').first();

    const savedConfirm = global.confirm

    // simulate cancelling confirmation
    global.confirm = () => false
    firstRemoveButton.simulate("click");
    classSetupForm.update();
    expect(teacherList.html()).toBe(afterAddHTML);

    // simulate accepting confirmation
    global.confirm = () => true
    firstRemoveButton.simulate("click");
    classSetupForm.update();
    expect(teacherList.html()).toBe(beforeAddHTML);

    global.confirm = savedConfirm
  });

})
