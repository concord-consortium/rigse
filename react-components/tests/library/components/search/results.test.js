/* globals describe it expect */
import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import SearchResults from 'components/search/results'
import { pack } from "../../helpers/pack"
import {mockJquery} from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

const mockedJQuery = () => ({
  val: () => ({
    length: 0
  })
})

describe('When I try to render search results', () => {

  mockJquery(mockedJQuery)

  it("should render with default props", () => {
    const results = [];
    const searchResults = Enzyme.shallow(<SearchResults results={results} />);
    expect(searchResults.html()).toBe(pack(`
      <div id="offering_list">
        <p style="font-weight:bold"> matching  selected criteria</p>
        <div class="results_container"></div>
      </div>
    `));
  });

  it("should render with results", () => {
    const results = [{
      type: "investigations",
      pagination: {
        total_items: 10,
        per_page: 20,
        start_item: 1,
        end_item: 20
      },
      materials: []
    }];
    const searchResults = Enzyme.shallow(<SearchResults results={results} />);
    expect(searchResults.html()).toBe(pack(`
      <div id="offering_list">
        <p style="font-weight:bold"><span>10 <a href="#" class=""></a></span> matching  selected criteria</p>
        <div class="results_container">
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
        </div>
      </div>
    `));
  });

});
