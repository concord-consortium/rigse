/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialDetails from 'components/search/material-details'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search material details', () => {

  it("should render with default props", () => {
    const material = {
      short_description: "short_description",
      activities: []
    }
    const materialDetails = Enzyme.shallow(<SMaterialDetails material={material} />);
    expect(materialDetails.html()).toBe(pack(`
      <div class="toggle-details">
        <i class="toggle-details-icon fa fa-chevron-down"></i>
        <i class="toggle-details-icon fa fa-chevron-up" style="display:none"></i>
        <div class="material-details" style="display:none">
          <div class="material-description one-col">
            <h3>Description</h3>
            <div>short_description</div>
          </div>
          <div class="material-activities"></div>
        </div>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const material = {
      short_description: "short_description",
      activities: [
        {id: 1, name: "activity 1"},
        {id: 2, name: "activity 2"}
      ],
      has_activities: true,
      has_pretest: true,
    }
    const materialDetails = Enzyme.shallow(<SMaterialDetails material={material} />);
    expect(materialDetails.html()).toBe(pack(`
      <div class="toggle-details">
        <i class="toggle-details-icon fa fa-chevron-down"></i>
        <i class="toggle-details-icon fa fa-chevron-up" style="display:none"></i>
        <div class="material-details" style="display:none">
          <div class="material-description two-cols">
            <h3>Description</h3>
            <div>short_description</div>
          </div>
          <div class="material-activities">
            <h4>Pre- and Post-tests available.</h4>
            <div>
              <h3>Activities</h3>
              <li>activity 1</li>
              <li>activity 2</li>
            </div>
          </div>
        </div>
      </div>
    `));
  });

})