/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { pack } from "../../helpers/pack"
import JoinClass, { JOIN_CLASS } from "../../../../src/library/components/portal-students/join-class"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render join class', () => {

  const renderedEnterClassword = pack(`
    <form class="form">
      <fieldset>
        <legend>Class Word</legend>
        <ul>
          <li>
            <label for="classWord">New Class Word: </label>
            <p>
              Not case sensitive
            </p>
            <input type="text" live="false" name="classWord" size="30">
          </li>
          <li>
            <input type="submit" value="Submit">
          </li>
        </ul>
        <p>
          A Class Word is created by a Teacher when he or she creates a new class. If you have been given the Class Word you can enter that word here to become a member of that class.
        </p>
      </fieldset>
    </form>
  `)

  const renderedEnterClasswordError = pack(`
    <form class="form">
      <fieldset>
        <p class="error">Invalid class word!</p>
        <legend>Class Word</legend>
        <ul>
          <li>
            <label for="classWord">New Class Word: </label>
            <p>
              Not case sensitive
            </p>
            <input type="text" live="false" name="classWord" size="30">
          </li>
          <li>
            <input type="submit" value="Submit">
          </li>
        </ul>
        <p>
          A Class Word is created by a Teacher when he or she creates a new class. If you have been given the Class Word you can enter that word here to become a member of that class.
        </p>
      </fieldset>
    </form>
  `)

  const renderedJoinClass = pack(`
    <form class="form">
      <fieldset>
        <legend>Class Word</legend>
        <p>
          The teacher of this class is Teacher Teacherson. Is this the class you want to join?
        </p>
        <p>
          Click 'Join' to continue registering for this class.
        </p>
        <p>
          <input type="submit" value="Join">
          <button>Cancel</button>
        </p>
      </fieldset>
    </form>
  `)

  it("should render enter classword dy default", () => {
    const joinClass = Enzyme.mount(<JoinClass />);
    expect(joinClass.html()).toBe(renderedEnterClassword)
  });

  describe("with an invalid class word", () => {
    mockJqueryAjaxSuccess({
      success: false,
      message: "Invalid class word!"
    })

    it("should render an error message when checking the classword", () => {
      const joinClass = Enzyme.mount(<JoinClass />);
      const classWordInput = joinClass.find("input[name='classWord']").first()
      const form = joinClass.find("form").first()

      expect(joinClass.html()).toBe(renderedEnterClassword)

      classWordInput.instance().value = "test"
      form.prop("onSubmit")({preventDefault: () => undefined})

      joinClass.update()
      expect(joinClass.html()).toBe(renderedEnterClasswordError)
    })

    it("should render an error message when joining", () => {
      const afterJoin = jest.fn()
      const joinClass = Enzyme.mount(<JoinClass afterJoin={afterJoin} />);
      joinClass.setState({ formState: JOIN_CLASS, classWord: "test", teacherName: "Teacher Teacherson" })
      const form = joinClass.find("form").first()

      expect(joinClass.html()).toBe(renderedJoinClass)

      form.prop("onSubmit")({preventDefault: () => undefined})

      joinClass.update()
      expect(joinClass.html()).toBe(renderedEnterClasswordError)
      expect(afterJoin).not.toHaveBeenCalled()
    })
  })

  describe("with a valid class word", () => {
    mockJqueryAjaxSuccess({
      success: true,
      data: {
        teacher_name: "Teacher Teacherson"
      }
    })

    it("should render the join form after checking the classword", () => {
      const joinClass = Enzyme.mount(<JoinClass />);
      const classWordInput = joinClass.find("input[name='classWord']").first()
      const form = joinClass.find("form").first()

      expect(joinClass.html()).toBe(renderedEnterClassword)

      classWordInput.instance().value = "test"
      form.prop("onSubmit")({preventDefault: () => undefined})

      joinClass.update()
      expect(joinClass.html()).toBe(renderedJoinClass)
    })

    it("should handle the cancel button in the join form", () => {
      const joinClass = Enzyme.mount(<JoinClass />);
      joinClass.setState({ formState: JOIN_CLASS, classWord: "test", teacherName: "Teacher Teacherson" })
      const cancelButton = joinClass.find("button").first()

      expect(joinClass.html()).toBe(renderedJoinClass)

      cancelButton.simulate("click")
      joinClass.update()

      expect(joinClass.html()).toBe(renderedEnterClassword)
    })

    it("should redirect after joining a class", () => {
      const afterJoin = jest.fn()
      const joinClass = Enzyme.mount(<JoinClass afterJoin={afterJoin} />);
      joinClass.setState({ formState: JOIN_CLASS, classWord: "test", teacherName: "Teacher Teacherson" })
      const form = joinClass.find("form").first()

      expect(joinClass.html()).toBe(renderedJoinClass)

      form.prop("onSubmit")({preventDefault: () => undefined})

      expect(afterJoin).toHaveBeenCalled()
    })
  })
})
