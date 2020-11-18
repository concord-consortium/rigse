/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { pack } from "../../helpers/pack"
import AddStandard from "../../../../src/library/components/eresources/add-standard"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render add standard', () => {

  const searchResult = {
    start: 0,
    count: 2,
    statements: [
      {"uri":"http://asn.jesandco.org/resources/S2454349","description":["Motion and Stability: Forces and Interactions"],"statement_label":"Disciplinary Core Idea","statement_notation":"K-PS2","education_level":["K"],"is_leaf":false,"doc":"NGSS","is_child_of":"http://asn.jesandco.org/resources/D2454348","is_part_of":"http://asn.jesandco.org/resources/D2454348","list_id":null,"is_applied":true},
      {"uri":"http://asn.jesandco.org/resources/S2454350","description":["Motion and Stability: Forces and Interactions","Students who demonstrate understanding can:"],"statement_label":"","statement_notation":"","education_level":["K"],"is_leaf":false,"doc":"NGSS","is_child_of":"http://asn.jesandco.org/resources/S2454349","is_part_of":"http://asn.jesandco.org/resources/D2454348","list_id":null,"is_applied":true}
    ]
  }

  mockJqueryAjaxSuccess(searchResult)

  const materialInfo = {
    material_id: 1,
    material_type: "external_activity",
  }

  const allStandards = [
    {uri: "http://asn.jesandco.org/resources/D2454348", name: "NGSS"},
    {uri: "http://asn.jesandco.org/resources/D10001D0", name: "NSES"},
    {uri: "http://asn.jesandco.org/resources/D2365735", name: "AAAS"},
    {uri: "http://asn.jesandco.org/resources/D10003FB", name: "CCSS"}
  ]

  it("should render", () => {
    const addStandard = Enzyme.mount(<AddStandard materialInfo={materialInfo} allStandards={allStandards} />);
    expect(addStandard.html()).toBe(pack(`
      <div>
        <table class="table">
          <tbody>
            <tr>
              <td>Standard Document</td>
              <td>
                <select>
                  <option value="http://asn.jesandco.org/resources/D2454348">NGSS</option>
                  <option value="http://asn.jesandco.org/resources/D10001D0">NSES</option>
                  <option value="http://asn.jesandco.org/resources/D2365735">AAAS</option>
                  <option value="http://asn.jesandco.org/resources/D10003FB">CCSS</option>
                </select>
              </td>
            </tr>
            <tr>
              <td>Notation</td>
              <td><input type="text"></td>
            </tr>
            <tr>
              <td>Label</td>
              <td><input type="text"></td>
            </tr>
            <tr>
              <td>Description</td>
              <td><input type="text"></td>
            </tr>
            <tr>
              <td>URI</td>
              <td><input type="text"></td>
            </tr>
          </tbody>
        </table>
        <div class="button"><button>Search</button></div>
      </div>
    `))
  });

  it("should support search", () => {
    const addStandard = Enzyme.mount(<AddStandard materialInfo={materialInfo} allStandards={allStandards} />);
    const button = addStandard.find("button").first()

    expect(addStandard.state()).toEqual({
      loadedStandards: false,
      searchError: undefined,
      searched: false,
      searching: false,
      standards: undefined,
    })

    button.simulate("click")

    expect(addStandard.state()).toEqual({
      loadedStandards: true,
      searchError: undefined,
      searched: true,
      searching: false,
      standards: searchResult,
    })

    // NOTE: the test of the rendering of the standards table is handled in its own test
  })

})
