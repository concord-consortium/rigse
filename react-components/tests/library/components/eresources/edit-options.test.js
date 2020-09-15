/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { pack } from "../../helpers/pack"
import EditOptions from "../../../../src/library/components/eresources/edit-options"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render edit options', () => {

  mockJqueryAjaxSuccess({
    success: true
  })

  const eresource = {
    id: 1,
    type: "external_activity",
    name: "Test Resource",
    publicationStatus: "published",
    gradeLevels: ["K","1","2"],
    subjectAreas: ["Math","Science"],
    sensors: ["Temperature"]
  }

  const props = {
    editPublicationStatus: true,
    publicationStates: ["draft","published","private"],
    editGradeLevels: true,
    allGradeLevels: ["K","1","2"],
    editSubjectAreas: true,
    allSubjectAreas: ["Math","Science"],
    editSensors: true,
    allSensors: ["Temperature"],
    editStandards: true,
    allStandards:[
      {uri: "http://asn.jesandco.org/resources/D2454348", name: "NGSS"},
      {uri: "http://asn.jesandco.org/resources/D10001D0", name: "NSES"},
      {uri: "http://asn.jesandco.org/resources/D2365735", name: "AAAS"},
      {uri: "http://asn.jesandco.org/resources/D10003FB", name: "CCSS"}
    ],
    eresource
  }

  const allFalseProps = {
    editPublicationStatus: false,
    editGradeLevels: false,
    editSubjectAreas: false,
    editSensors: false,
    editStandards: false,
    eresource
  }

  it("should render", () => {
    const editOptions = Enzyme.mount(<EditOptions {...props} />);
    expect(editOptions.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div class="dialog">
          <div class="title">Edit Options</div>
          <div class="container">
            <h3>External Activity: Test Resource</h3>
            <form>
              <fieldset>
                <legend>Publication Status</legend>
                <select name="publication_status">
                  <option value="draft">draft</option>
                  <option value="published" selected="">published</option>
                  <option value="private">private</option>
                </select>
              </fieldset>
              <fieldset>
                <legend>Grade Levels</legend>
                <div class="checkboxList"><span><input type="checkbox" name="grade_levels[]" value="K" checked="">K</span><span><input type="checkbox" name="grade_levels[]" value="1" checked="">1</span><span><input type="checkbox" name="grade_levels[]" value="2" checked="">2</span></div>
              </fieldset>
              <fieldset>
                <legend>Subject Areas</legend>
                <div class="checkboxList"><span><input type="checkbox" name="subject_areas[]" value="Math" checked="">Math</span><span><input type="checkbox" name="subject_areas[]" value="Science" checked="">Science</span></div>
              </fieldset>
              <fieldset>
                <legend>Sensors</legend>
                <div class="checkboxList"><span><input type="checkbox" name="sensors[]" value="Temperature" checked="">Temperature</span></div>
              </fieldset>
              <fieldset>
                <legend>Standards</legend>
                <div>
                  <div class="sectionLabel">Applied Standards</div>
                  <div class="info">No standards applied</div>
                </div>
                <div>
                  <div class="addStandards">
                    <div class="addStandardsLabel">Add Standards</div>
                    <div><button>Add</button></div>
                  </div>
                </div>
              </fieldset>
            </form>
          </div>
          <div class="buttons"><button>Save</button><button>Cancel</button></div>
        </div>
      </div>
    `))
  });

  it("should render with all edits set to false", () => {
    const editOptions = Enzyme.mount(<EditOptions {...allFalseProps} />);
    expect(editOptions.html()).toBe(pack(`
      <div class="modal">
        <div class="background"></div>
        <div class="dialog">
          <div class="title">Edit Options</div>
          <div class="container">
            <h3>Resource: Test Resource</h3>
            <form></form>
          </div>
          <div class="buttons"><button>Save</button><button>Cancel</button></div>
        </div>
      </div>
    `))
  });

  it("should handle cancel", () => {
    const onCancel = jest.fn()
    const globalConsole = global.console
    global.console = {
      error: onCancel
    }
    const editOptions = Enzyme.mount(<EditOptions {...allFalseProps} />);
    const cancelButton = editOptions.find("button").last()

    cancelButton.simulate("click")
    expect(onCancel).toHaveBeenCalledWith("No parentId parameter found to unmount component")

    global.console = globalConsole
  })

  it("should handle submit", () => {
    const onSubmit = jest.fn()
    const savedLocation = window.location
    delete global.window.location
    global.window.location = {
      reload: onSubmit
    }

    const editOptions = Enzyme.mount(<EditOptions {...allFalseProps} />);
    const buttons = editOptions.find("button")
    const submitButton = buttons.at(buttons.length - 2)

    submitButton.simulate("click")
    expect(onSubmit).toHaveBeenCalled()

    global.location = savedLocation
  })

})
