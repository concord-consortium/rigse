/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SearchResultGroup from 'components/search/result-group'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render search result group', () => {
  it("should render with default props", () => {
    const group = {
      type: "investigations",
      pagination: {
        total_items: 10,
        per_page: 20,
        start_item: 1,
        end_item: 20
      },
      materials: []
    }
    const searchResultGroup = Enzyme.shallow(<SearchResultGroup group={group} />);
    expect(searchResultGroup.html()).toBe(pack(`
      <div id="investigations_bookmark" class="materials_container investigations">
        <div class="material_list_header"></div>
        <div>
          <p class="border_top">
            <span>Displaying <b>all 10</b></span>
          </p>
          <div class="pagination"></div>
          <div class="material_list"></div>
          <br/>
          <div class="pagination"></div>
        </div>
      </div>
    `));
  });

});
