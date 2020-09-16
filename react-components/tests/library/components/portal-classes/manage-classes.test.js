/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import ManageClasses from 'components/portal-classes/manage-classes'
import { pack } from "../../helpers/pack"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render manage classes', () => {

  mockJqueryAjaxSuccess({
    success: true
  })

  const classes = [
    {
      id: 1,
      name: "test class 1",
      classWord: "test_class_1",
      description: "this is a test class 1",
      active: true,
    },
    {
      id: 2,
      name: "test class 2",
      classWord: "test_class_2",
      description: "this is a test class 2",
      active: false
    },
    {
      id: 3,
      name: "test class 3",
      classWord: "test_class_3",
      description: "this is a test class 3",
      active: true
    }
  ]

  it("should render", () => {
    const manageClasses = Enzyme.mount(<ManageClasses classes={classes} />);
    expect(manageClasses.html()).toBe(pack(`
      <div class="manageClassesSummary">My Classes (3 Total, 2 Active)</div>
      <div class="manageClassesTable">
        <div class="manageClassRow">
          <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
          <span class="manageClassName">test class 1</span>
          <span class="manageClassButtons">
            <button class="textButton">Archive</button>
            <button class="textButton">Copy</button>
          </span>
        </div>
        <div class="manageClassRow">
          <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
          <span class="manageClassName"><strike>test class 2</strike></span>
          <span class="manageClassButtons">
            <button class="textButton">Unarchive</button>
            <button class="textButton">Copy</button>
          </span>
        </div>
        <div class="manageClassRow">
          <span class="iconCell"><span class="sortIcon icon-sort"></span></span>
          <span class="manageClassName">test class 3</span>
          <span class="manageClassButtons">
            <button class="textButton">Archive</button>
            <button class="textButton">Copy</button>
          </span>
        </div>
      </div>
    `));
  });

  it("should handle toggling activation", () => {
    const manageClasses = Enzyme.mount(<ManageClasses classes={classes} />);
    const toggleActiveButton = () => manageClasses.find(".manageClassRow").first().find(".manageClassButtons").childAt(0)

    expect(toggleActiveButton().html()).toBe('<button class="textButton">Archive</button>')

    toggleActiveButton().simulate("click")
    manageClasses.update()
    expect(toggleActiveButton().html()).toBe('<button class="textButton">Unarchive</button>')

    toggleActiveButton().simulate("click")
    manageClasses.update()
    expect(toggleActiveButton().html()).toBe('<button class="textButton">Archive</button>')
  })

  it("should handle copying", () => {
    const manageClasses = Enzyme.mount(<ManageClasses classes={classes} />);
    const copyButton = manageClasses.find(".manageClassRow").first().find(".manageClassButtons").childAt(1)

    expect(manageClasses.html()).not.toContain('<div class="copyDialogLightbox">')
    copyButton.simulate("click")
    manageClasses.update()
    expect(manageClasses.html()).toContain('<div class="copyDialogLightbox">')
    expect(manageClasses.html()).toContain('<td><input name="name" value="Copy of test class 1"></td>')

    // NOTE: the copy dialog is tested in its own test file
  })

})
