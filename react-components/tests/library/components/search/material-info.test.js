/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialInfo from 'components/search/material-info'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search material info', () => {

  it("should render with default props", () => {
    const material = {
      links: {},
      material_properties: ""
    }
    const materialInfo = Enzyme.shallow(<SMaterialInfo material={material} />);
    expect(materialInfo.html()).toBe(pack(`
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
                <td>
                  <span class="material_header">
                    <span class="material_meta_data">
                      <span class="RunsInBrowser">Runs in browser</span>
                      <span class="is_community">Community</span>
                      <span class="publication_status"></span>
                    </span>
                    <br/>
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
    `));
  });

  it("should render with optional props #1", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      lara_activity_or_sequence: true,
      publication_status: "draft",
      parent: {
        type: "parent type",
        name: "parent name"
      },
      credits: "credits",
      assigned_classes: ["class 1"],
      links: {
        preview: {
          url: "http://example.com/preview",
          text: "preview text"
        },
        print_url: {
          url: "http://example.com/print_url",
          text: "print_url text"
        },
        external_lara_edit: {
          url: "http://example.com/external_lara_edit",
          text: "external_lara_edit text"
        },
        external_edit: {
          url: "http://example.com/external_edit",
          text: "external_edit text"
        },
        external_copy: {
          url: "http://example.com/external_copy",
          text: "external_copy text"
        },
        teacher_guide: {
          url: "http://example.com/teacher_guide",
          text: "teacher_guide text"
        },
        assign_material: {
          url: "http://example.com/assign_material",
          text: "assign_material text"
        },
        assign_collection: {
          url: "http://example.com/assign_collection",
          text: "assign_collection text"
        },
        unarchive: {
          url: "http://example.com/unarchive",
          text: "unarchive text"
        },
        browse: {
          url: "http://example.com/browse"
        },
        edit: {
          url: "http://example.com/edit",
          text: "edit text"
        },
        external_edit_iframe: {
          url: "http://example.com/external_edit_iframe",
          text: "external_edit_iframe text"
        }
      }
    }
    const materialInfo = Enzyme.shallow(<SMaterialInfo material={material} />);
    expect(materialInfo.html()).toBe(pack(`
      <div>
        <div style="overflow:hidden">
          <table width="100%">
            <tbody>
              <tr>
                <td>
                  <div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/preview" class="button">preview text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/print_url" class="button">print_url text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/external_lara_edit" class="button">external_lara_edit text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/external_copy" class="button">external_copy text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/teacher_guide" class="button">teacher_guide text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/assign_material" class="button">assign_material text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/assign_collection" class="button">assign_collection text</a>
                    </div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/unarchive" class="button">unarchive text</a>
                    </div>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <span class="material_header">
                    <span class="material_meta_data">
                      <span class="RequiresDownload">Requires download</span>
                      <span class="is_official">Official</span>
                      <span class="publication_status">draft</span>
                    </span>
                    <br/>
                    <a href="http://example.com/browse">material name</a>
                    <span class="superTiny">
                      <a href="http://example.com/edit" class="button">edit text</a>
                    </span>
                  </span>
                  <span>from parent type &quot;parent name&quot;</span>
                  <div>
                    <span style="font-weight:bold">By credits</span>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <span class="assignedTo">(Assigned to class 1)</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    `));
  });

  it("should render with optional props #2", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      lara_activity_or_sequence: false,
      publication_status: "draft",
      material_type: "Collection",
      links: {
        external_edit: {
          url: "http://example.com/external_edit",
          text: "external_edit text"
        },
        assign_material: {
          url: "http://example.com/assign_material",
          text: "assign_material text"
        }
      }
    }
    const materialInfo = Enzyme.shallow(<SMaterialInfo material={material} />);
    expect(materialInfo.html()).toBe(pack(`
      <div>
        <div style="overflow:hidden">
          <table width="100%">
            <tbody>
              <tr>
                <td>
                  <div>
                    <div style="float:right;margin-right:5px">
                      <a href="http://example.com/external_edit" class="button">external_edit text</a>
                    </div>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <span class="material_header">
                    <span class="material_meta_data">
                      <span class="RequiresDownload">Requires download</span>
                      <span class="is_official">Official</span>
                      <span class="publication_status">draft</span>
                    </span>
                    <br/>
                    material name
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
    `));
  });

})