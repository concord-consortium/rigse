/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { SMaterialLinks, SGenericLink, SMaterialLink, SMaterialDropdownLink } from 'components/search/material-links'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search generic link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text"
    }
    const genericLink = Enzyme.shallow(<SGenericLink link={link} />);
    expect(genericLink.html()).toBe(pack(`
      <a href="http://example.com/url" class="button">text</a>
    `));
  });

  it("should render with optional props", () => {
    const link = {
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text"
    }
    const genericLink = Enzyme.shallow(<SGenericLink link={link} />);
    expect(genericLink.html()).toBe(pack(`
      <a href="http://example.com/url" class="className" target="target" data-cc-confirm="ccConfirm">text</a>
    `));
  });
});

describe('When I try to render search material link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text"
    }
    const materialLink = Enzyme.shallow(<SMaterialLink link={link} />);
    expect(materialLink.html()).toBe(pack(`
      <div style="float:right;margin-right:5px">
        <a href="http://example.com/url" class="button">text</a>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const link = {
      key: "key",
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text"
    }
    const materialLink = Enzyme.shallow(<SMaterialLink link={link} />);
    expect(materialLink.html()).toBe(pack(`
      <div style="float:right;margin-right:5px">
        <a href="http://example.com/url" class="className" target="target" data-cc-confirm="ccConfirm">text</a>
      </div>
    `));
  });
});

describe('When I try to render search dropdown link', () => {
  it("should render with default props", () => {
    const link = {
      url: "http://example.com/url",
      text: "text",
      options: []
    }
    const dropdownLink = Enzyme.shallow(<SMaterialDropdownLink link={link} />);
    expect(dropdownLink.html()).toBe(pack(`
      <div style="float:right">
        <a href="http://example.com/url" class="button">text</a>
        <div class="Expand_Collapse Expand_Collapse_preview" style="display:none"></div>
      </div>
    `));
  });

  it("should render with optional props", () => {
    const link = {
      key: "key",
      url: "http://example.com/url",
      className: "className",
      target: "target",
      ccConfirm: "ccConfirm",
      text: "text",
      options: [
        {url: "http://example.com/option1", text: "option 1"},
        {url: "http://example.com/option2", text: "option 2"}
      ]
    }
    const dropdownLink = Enzyme.shallow(<SMaterialDropdownLink link={link} />);
    expect(dropdownLink.html()).toBe(pack(`
      <div style="float:right">
        <a href="http://example.com/url" class="className" target="target" data-cc-confirm="ccConfirm">text</a>
        <div class="Expand_Collapse Expand_Collapse_preview" style="display:none">
          <div class="preview_link">
            <a href="http://example.com/option1" class="button">option 1</a>
          </div>
          <div class="preview_link">
            <a href="http://example.com/option2" class="button">option 2</a>
          </div>
        </div>
      </div>
    `));
  });
});

describe('When I try to render search material links', () => {
  it("should render", () => {
    const links = [
      {
        key: "key1",
        url: "http://example.com/url",
        className: "className",
        target: "target",
        ccConfirm: "ccConfirm",
        text: "text"
      },
      {
        type: "dropdown",
        key: "key2",
        url: "http://example.com/url",
        className: "className",
        target: "target",
        ccConfirm: "ccConfirm",
        text: "text",
        options: [
          {url: "http://example.com/option1", text: "option 1"},
          {url: "http://example.com/option2", text: "option 2"}
        ]
      }
    ]
    const materialsLinks = Enzyme.shallow(<SMaterialLinks links={links} />);
    expect(materialsLinks.html()).toBe(pack(`
      <div>
        <div style="float:right;margin-right:5px">
          <a href="http://example.com/url" class="className" target="target" data-cc-confirm="ccConfirm">text</a>
        </div>
        <div style="float:right">
          <a href="http://example.com/url" class="className" target="target" data-cc-confirm="ccConfirm">text</a>
          <div class="Expand_Collapse Expand_Collapse_preview" style="display:none">
            <div class="preview_link">
              <a href="http://example.com/option1" class="button">option 1</a>
            </div>
            <div class="preview_link">
              <a href="http://example.com/option2" class="button">option 2</a>
            </div>
          </div>
        </div>
      </div>
    `));
  });
});