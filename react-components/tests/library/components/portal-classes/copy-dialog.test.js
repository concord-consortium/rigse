/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import CopyDialog from 'components/portal-classes/copy-dialog'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render class copy dialog', () => {

  const clazz = {
    name: "test class",
    classWord: "test_class",
    description: "this is a test class"
  }

  it("should render", () => {
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} />);
    expect(copyDialog.html()).toBe(pack(`
      <div class="copyDialogLightbox">
        <div class="copyDialogBackground"></div>
        <div class="copyDialog">
          <div class="copyTitle">Copy Class</div>
          <form>
            <table>
              <tbody>
                <tr>
                  <td><label for="name">Name</label></td>
                  <td><input name="name" value="Copy of test class"></td>
                </tr>
                <tr>
                  <td><label for="class_word">Class Word</label></td>
                  <td><input name="class_word" value="Copy of test_class"></td>
                </tr>
                <tr>
                  <td class="description"><label for="description">Description</label></td>
                  <td><textarea name="description">this is a test class</textarea></td>
                </tr>
                <tr>
                  <td colspan="2" class="buttons"><button>Save</button><button>Cancel</button></td>
                </tr>
              </tbody>
            </table>
          </form>
        </div>
      </div>
    `));
  });

  it("should handle cancel", () => {
    const handleCancel = jest.fn()
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} handleCancel={handleCancel} />);
    const cancelButton = copyDialog.find(".buttons").childAt(1)

    cancelButton.simulate("click")
    copyDialog.update()
    expect(handleCancel).toHaveBeenCalled()
  });

  it("should disable saving when name is whitespace", () => {
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} />);
    const nameInput = copyDialog.find("input[name='name']").first()
    // this needs to be a function so we re-find after the update
    const saveButton = () => copyDialog.find(".buttons").childAt(0)

    expect(saveButton().prop('disabled')).toBe(false)
    expect(nameInput.instance().value).toBe("Copy of test class")

    nameInput.prop("onChange")({target: {value: '   '}})
    copyDialog.update()
    expect(saveButton().prop('disabled')).toBe(true)
  });

  it("should disable saving when classWord is whitespace", () => {
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} />);
    const classWordInput = copyDialog.find("input[name='class_word']").first()
    // this needs to be a function so we re-find after the update
    const saveButton = () => copyDialog.find(".buttons").childAt(0)

    expect(saveButton().prop('disabled')).toBe(false)
    expect(classWordInput.instance().value).toBe("Copy of test_class")

    classWordInput.prop("onChange")({target: {value: '   '}})
    copyDialog.update()
    expect(saveButton().prop('disabled')).toBe(true)
  });

  it("should handle save", () => {
    const handleSave = jest.fn()
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} handleSave={handleSave} />);
    const saveButton = copyDialog.find(".buttons").childAt(0)

    expect(saveButton.html()).toBe('<button>Save</button>')

    saveButton.simulate("click")
    copyDialog.update()

    expect(handleSave).toHaveBeenCalledWith({
      name: "Copy of test class",
      classWord: "Copy of test_class",
      description: "this is a test class"
    })
  });

  it("should updating the save button text", () => {
    const copyDialog = Enzyme.mount(<CopyDialog clazz={clazz} saving={true} />);
    const saveButton = copyDialog.find(".buttons").childAt(0)
    expect(saveButton.html()).toBe('<button disabled="">Saving ...</button>')
  });

})
