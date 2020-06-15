/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialsList from 'components/search/materials-list'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search materials list', () => {
  it("should render with default props", () => {
    const materials = [{
      id: 1,
      icon: {
        url: "http://example.com/icon"
      },
      links: {},
      material_properties: "",
      activities: []
    }, {
      id: 2,
      icon: {
        url: "http://example.com/icon"
      },
      links: {},
      material_properties: "",
      activities: []
    }]
    const materialsList = Enzyme.shallow(<SMaterialsList materials={materials} />);
    expect(materialsList.html()).toBe(pack(`
      <div class="material_list">
        <div class="material_list_item" data-material_id="1" id="search_undefined_1">
          <div class="main-part">
            <div class="material_icon" style="border:0px">
              <a class="thumb_link"><img src="http://example.com/icon" width="100%"/></a>
              <div class="legacy-favorite">★</div>
              <div class="legacy-favorite legacy-favorite-outline" style="color:#CCCCCC">☆</div>
            </div>
            <div>
              <div style="overflow:hidden">
                <table width="100%">
                  <tbody>
                    <tr>
                      <td>
                        <div></div>
                      </td>
                    </tr>
                    <tr>
                      <td><span class="material_header"><span class="material_meta_data"><span class="RunsInBrowser">Runs in browser</span><span class="is_community">Community</span><span class="publication_status"></span></span><br/></span></td>
                    </tr>
                    <tr>
                      <td></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div class="material_body"></div>
          </div>
          <div class="toggle-details">
            <i class="toggle-details-icon fa fa-chevron-down"></i><i class="toggle-details-icon fa fa-chevron-up" style="display:none"></i>
            <div class="material-details" style="display:none">
              <div class="material-description one-col">
                <h3>Description</h3>
                <div></div>
              </div>
              <div class="material-activities"></div>
            </div>
          </div>
        </div>
        <div class="material_list_item" data-material_id="2" id="search_undefined_2">
          <div class="main-part">
            <div class="material_icon" style="border:0px">
              <a class="thumb_link"><img src="http://example.com/icon" width="100%"/></a>
              <div class="legacy-favorite">★</div>
              <div class="legacy-favorite legacy-favorite-outline" style="color:#CCCCCC">☆</div>
            </div>
            <div>
              <div style="overflow:hidden">
                <table width="100%">
                  <tbody>
                    <tr>
                      <td>
                        <div></div>
                      </td>
                    </tr>
                    <tr>
                      <td><span class="material_header"><span class="material_meta_data"><span class="RunsInBrowser">Runs in browser</span><span class="is_community">Community</span><span class="publication_status"></span></span><br/></span></td>
                    </tr>
                    <tr>
                      <td></td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div class="material_body"></div>
          </div>
          <div class="toggle-details">
            <i class="toggle-details-icon fa fa-chevron-down"></i><i class="toggle-details-icon fa fa-chevron-up" style="display:none"></i>
            <div class="material-details" style="display:none">
              <div class="material-description one-col">
                <h3>Description</h3>
                <div></div>
              </div>
              <div class="material-activities"></div>
            </div>
          </div>
        </div>
      </div>
    `));
  });

});
