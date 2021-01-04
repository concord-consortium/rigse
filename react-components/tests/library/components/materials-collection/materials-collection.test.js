/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import MaterialsCollection from 'components/materials-collection/materials-collection'
import { pack } from "../../helpers/pack"
import {mockJqueryAjaxSuccess} from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

global.Portal = {
  API_V1: {
    MATERIALS_BIN_COLLECTIONS: 'http://fake-url'
  }
}

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

describe('When I try to render materials collection', () => {
  let materialsCollection;

  mockJqueryAjaxSuccess([{materials}])

  describe("with required props", () => {
    beforeEach(() => {
      materialsCollection = Enzyme.mount(<MaterialsCollection
        materials={materials}
        collection={1}
      />)
    })

    it("should set the default props", () => {
      expect(materialsCollection.props()).toEqual({
        collection: 1,
        header: null,
        limit: Infinity,
        materials: [{
          id: 1,
          activities: [],
          icon: {
            url: "http://example.com/icon"
          },
          links: {},
          material_properties: ""
        }, {
          id: 2,
          activities: [],
          icon: {
            url: "http://example.com/icon"
          },
          links: {},
          material_properties: ""
        }],
        onDataLoad: null,
        randomize: false
      });
    });

    it("should call the ajax request", () => {
      expect(global.jQuery.ajax).toHaveBeenCalled();
    })

    it("should render the default props", () => {
      expect(materialsCollection.html()).toBe(pack(`
      <div>
      <div class="material_list">
        <div class="material_list_item" data-material_id="1" id="search_undefined_1">
          <div class="main-part">
            <div class="material_icon" style="border: 0px;">
              <a class="thumb_link"><img src="http://example.com/icon" width="100%"></a>
              <div class="legacy-favorite">★</div>
              <div class="legacy-favorite legacy-favorite-outline" style="color: rgb(204, 204, 204);">☆</div>
            </div>
            <div>
              <div style="overflow: hidden;">
                <table width="100%">
                  <tbody>
                    <tr>
                      <td>
                        <div></div>
                      </td>
                    </tr>
                    <tr>
                      <td>
                        <span class="material_header">
                        <span class="material_meta_data">
                        <span class="RunsInBrowser">Runs in browser</span>
                        <span class="is_community">Community</span>
                        <span class="publication_status"></span>
                        </span>
                        <br>
                        </span>
                      </td>
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
            <i class="toggle-details-icon fa fa-chevron-down"></i>
            <i class="toggle-details-icon fa fa-chevron-up" style="display: none;"></i>
            <div class="material-details" style="display: none;">
              <div class="material-description one-col">
                <h3>Description</h3>
                <div>
                </div>
              </div>
              <div class="material-activities"></div>
            </div>
          </div>
        </div>
        <div class="material_list_item" data-material_id="2" id="search_undefined_2">
          <div class="main-part">
            <div class="material_icon" style="border: 0px;">
              <a class="thumb_link"><img src="http://example.com/icon" width="100%"></a>
              <div class="legacy-favorite">★</div>
              <div class="legacy-favorite legacy-favorite-outline" style="color: rgb(204, 204, 204);">☆</div>
            </div>
            <div>
              <div style="overflow: hidden;">
                <table width="100%">
                  <tbody>
                    <tr>
                      <td>
                        <div></div>
                      </td>
                    </tr>
                    <tr>
                      <td><span class="material_header"><span class="material_meta_data"><span class="RunsInBrowser">Runs in browser</span><span class="is_community">Community</span><span class="publication_status"></span></span><br></span></td>
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
            <i class="toggle-details-icon fa fa-chevron-down"></i><i class="toggle-details-icon fa fa-chevron-up" style="display: none;"></i>
            <div class="material-details" style="display: none;">
              <div class="material-description one-col">
                <h3>Description</h3>
                <div></div>
              </div>
              <div class="material-activities"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
    `));
    })
  })

  describe("with optional props", () => {
    const onDataLoad = jest.fn();

    beforeEach(() => {
      materialsCollection = Enzyme.mount(<MaterialsCollection
        materials={materials}
        collection={1}
        header="this is the header"
        limit={2}
        onDataLoad={onDataLoad}
      />)
    })

    it("should call onDataLoad", () => {
      expect(onDataLoad).toHaveBeenCalledWith(materials)
    })

    it("should render the optional props", () => {
      expect(materialsCollection.html()).toBe(pack(`
        <div>
          <h1 class="collection-header">this is the header</h1>
          <div class="material_list">
            <div class="material_list_item" data-material_id="1" id="search_undefined_1">
              <div class="main-part">
                <div class="material_icon" style="border: 0px;"><a class="thumb_link"><img src="http://example.com/icon" width="100%"></a>
                <div class="legacy-favorite">★</div>
                <div class="legacy-favorite legacy-favorite-outline" style="color: rgb(204, 204, 204);">☆
              </div>
            </div>
            <div>
              <div style="overflow: hidden;">
              <table width="100%">
                <tbody>
                  <tr>
                    <td>
                      <div></div>
                    </td>
                  </tr>
                  <tr>
                    <td><span class="material_header"><span class="material_meta_data"><span class="RunsInBrowser">Runs in browser</span><span class="is_community">Community</span><span class="publication_status"></span></span><br></span></td>
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
          <i class="toggle-details-icon fa fa-chevron-down"></i><i class="toggle-details-icon fa fa-chevron-up" style="display: none;"></i><div class="material-details" style="display: none;">
          <div class="material-description one-col">
            <h3>Description</h3>
            <div></div>
          </div>
          <div class="material-activities"></div>
        </div>
        </div></div>
        <div class="material_list_item" data-material_id="2" id="search_undefined_2">
          <div class="main-part">
            <div class="material_icon" style="border: 0px;"><a class="thumb_link"><img src="http://example.com/icon" width="100%"></a>
            <div class="legacy-favorite">★</div>
            <div class="legacy-favorite legacy-favorite-outline" style="color: rgb(204, 204, 204);">☆
          </div>
        </div>
        <div>
          <div style="overflow: hidden;">
          <table width="100%">
            <tbody>
              <tr>
                <td>
                  <div></div>
                </td>
              </tr>
              <tr>
                <td><span class="material_header"><span class="material_meta_data"><span class="RunsInBrowser">Runs in browser</span><span class="is_community">Community</span><span class="publication_status"></span></span><br></span></td>
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
          <i class="toggle-details-icon fa fa-chevron-down"></i><i class="toggle-details-icon fa fa-chevron-up" style="display: none;"></i><div class="material-details" style="display: none;">
          <div class="material-description one-col">
            <h3>Description</h3>
            <div></div>
          </div>
          <div class="material-activities"></div>
        </div>
        </div></div></div></div>
          `));
    })
  })

})
