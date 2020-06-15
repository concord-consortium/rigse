/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import StudentForm from 'components/signup/student_form'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

global.Portal = {
  API_V1: {
    CLASSWORD: "http://example.com/classword",
    STUDENTS: "http://example.com/students",
  }
}

describe('When I try to render signup student form', () => {

  it("should render", () => {
    const studentForm = Enzyme.mount(<StudentForm />);
    expect(studentForm.html()).toBe(pack(`
      <form>
        <dl>
          <dt>Class Word</dt>
          <dd>
            <div class="text-input class_word">
              <input type="text" placeholder="Class Word (not case sensitive)" value="">
              <div class="input-error"></div>
            </div>
          </dd>
        </dl>
        <div class="privacy-policy">
          By clicking Register!, you agree to our <a href="https://concord.org/privacy-policy" target="_blank">privacy policy.</a>
        </div>
        <div class="submit-button-container">
          <button class="submit-btn" type="submit" disabled="">Register!</button>
        </div>
      </form>
    `));
  });

})