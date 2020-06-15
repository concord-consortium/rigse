/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SPaginationInfo from 'components/search/pagination-info'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search pagination info', () => {
  it("should render with total_items <= per_page", () => {
    const info = {
      total_items: 10,
      per_page: 20,
      start_item: 1,
      end_item: 20
    }
    const paginationInfo = Enzyme.shallow(<SPaginationInfo info={info} />);
    expect(paginationInfo.html()).toBe(pack(`
      <span>Displaying <b>all 10</b></span>
    `));
  });

  it("should render with total_items > per_page", () => {
    const info = {
      total_items: 100,
      per_page: 20,
      start_item: 1,
      end_item: 20
    }
    const paginationInfo = Enzyme.shallow(<SPaginationInfo info={info} />);
    expect(paginationInfo.html()).toBe(pack(`
      <span>Displaying <b>1 - 20</b> of <b>100</b></span>
    `));
  });
});
