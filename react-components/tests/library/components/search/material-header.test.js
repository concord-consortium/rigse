/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SMaterialHeader from 'components/search/material-header'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search material header', () => {

  it("should render with default props", () => {
    const material = {
      material_properties: "",
      publication_status: "published",
      links: {}
    }
    const materialHeader = Enzyme.shallow(<SMaterialHeader material={material} />);
    expect(materialHeader.html()).toBe(pack(`
      <span class="material_header">
        <span class="material_meta_data">
          <span class="RunsInBrowser">Runs in browser</span>
          <span class="is_community">Community</span>
        </span>
        <br/>
      </span>
    `));
  });

  it("should render with optional props", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      publication_status: "draft",
      links: {
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
    const materialHeader = Enzyme.shallow(<SMaterialHeader material={material} />);
    expect(materialHeader.html()).toBe(pack(`
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
        <span class="superTiny">
          <a href="http://example.com/external_edit_iframe" class="button">external_edit_iframe text</a>
        </span>
      </span>
    `));
  });


})