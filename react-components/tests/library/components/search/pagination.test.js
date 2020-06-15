/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SPagination from 'components/search/pagination'
import { pack } from "../../helpers/pack"
import {mockJquery} from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

const node = {
  value: 1,
  paging: (total, options) => {
    node.options = options;
  }
}
const pagingPluginFormat = (method) => node.options.onFormat.call(node, method);

window.ReactDOM = {
  findDOMNode: () => node
};

describe('When I try to render search pagination', () => {
  mockJquery((node) => node)

  it("should render an empty div", () => {
    const info = {}
    const pagination = Enzyme.shallow(<SPagination info={info} />);
    expect(pagination.html()).toBe(pack(`
      <div class="pagination"></div>
    `));
  });

  it("should use the jQuery paging plugin", () => {
    node.active = false;
    expect(pagingPluginFormat("block")).toBe(pack(`
      <span class='disabled'>1</span>
    `));
    expect(pagingPluginFormat("next")).toBe(pack(`
      <span class="disabled">Next →</span>
    `));
    expect(pagingPluginFormat("prev")).toBe(pack(`
      <span class="disabled">← Previous</span>
    `));
    expect(pagingPluginFormat("first")).toBe(pack(`
      <span class="disabled">|&lt;</span>
    `));
    expect(pagingPluginFormat("last")).toBe(pack(`
      <span class="disabled">&gt;|</span>
    `));
    expect(pagingPluginFormat("leap")).toBe("");
    expect(pagingPluginFormat("fill")).toBe("");
    expect(pagingPluginFormat("")).toBe("");

    node.active = true;
    expect(pagingPluginFormat("block")).toBe(pack(`
      <em><a href='#' class='page'>1</a></em>
    `));
    expect(pagingPluginFormat("next")).toBe(pack(`
      <a href='#' class='next'>Next →</a>
    `));
    expect(pagingPluginFormat("prev")).toBe(pack(`
      <a href='#' class='prev'>← Previous</a>
    `));
    expect(pagingPluginFormat("first")).toBe(pack(`
      <a href='#' class='first'>|&lt;</a>
    `));
    expect(pagingPluginFormat("last")).toBe(pack(`
      <a href='#' class='last'>&gt;|</a>
    `));
    expect(pagingPluginFormat("leap")).toBe("   ");
    expect(pagingPluginFormat("fill")).toBe("...");
    expect(pagingPluginFormat("")).toBe("");
  });
});
