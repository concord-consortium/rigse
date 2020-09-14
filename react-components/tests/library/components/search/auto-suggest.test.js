/* globals describe it expect */

import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import AutoSuggest from 'components/search/auto-suggest'
import { pack } from "../../helpers/pack"
import { mockJqueryAjaxSuccess } from "../../helpers/mock-jquery"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render autosuggest', () => {

  mockJqueryAjaxSuccess({
    search_term: "test",
    suggestions: [
      "test 1",
      "test 2",
      "test 3"
    ]
  })

  it("should render with default props", () => {
    const autoSuggest = Enzyme.mount(<AutoSuggest />);
    expect(autoSuggest.html()).toBe(pack(`
      <div class="autoSuggest">
        <input type="text" autocomplete="off" value="">
      </div>
    `));
  });

  it("should render with a query prop and show the suggestions", () => {
    const autoSuggest = Enzyme.mount(<AutoSuggest query="test" />);
    expect(autoSuggest.html()).toBe(pack(`
      <div class="autoSuggest">
        <input type="text" autocomplete="off" value="test">
        <div id="suggestions" class="suggestions" style="width: 0px;">
          <div class="suggestion">test 1</div>
          <div class="suggestion">test 2</div>
          <div class="suggestion">test 3</div>
        </div>
      </div>
    `));
  });

  it("should search on input change and show the suggestions", () => {
    const autoSuggest = Enzyme.mount(<AutoSuggest />);
    const input = autoSuggest.find("input").first()

    // mock width as it defaults to 0 in jest
    const savedGBCR = input.getDOMNode().getBoundingClientRect
    input.getDOMNode().getBoundingClientRect = jest.fn().mockImplementation(() => {
      return { width: 100 }
    })

    expect(autoSuggest.state().query).toBe("")
    input.prop("onChange")({target: {value: "test"}})

    expect(autoSuggest.state()).toEqual({
      query: 'test',
      suggestions: [ 'test 1', 'test 2', 'test 3' ],
      selectedSuggestionIndex: -1,
      showSuggestions: true
    })
    expect(autoSuggest.html()).toBe(pack(`
      <div class="autoSuggest">
        <input type="text" autocomplete="off" value="test">
        <div id="suggestions" class="suggestions" style="width: 100px;">
          <div class="suggestion">test 1</div>
          <div class="suggestion">test 2</div>
          <div class="suggestion">test 3</div>
        </div>
      </div>
    `));

    input.getDOMNode().getBoundingClientRect = savedGBCR
  });

  describe("after a search", () => {

    it("should handle navigation keys", () => {

      const onChange = jest.fn()
      const autoSuggest = Enzyme.mount(<AutoSuggest query="test" onChange={onChange} />);
      const input = autoSuggest.find("input").first()
      const keyDown = (keyCode) => input.prop("onKeyDown")({keyCode, preventDefault: () => undefined, stopPropagation: () => undefined})

      // do the query
      input.prop("onChange")({target: {value: "test"}})
      expect(autoSuggest.html()).toContain('<div class="suggestion">test 1</div>')

      // down arrow selects first
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(-1)
      keyDown(40)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(0)

      // down arrow selects next
      keyDown(40)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(1)

      // up arrow selects first
      keyDown(38)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(0)

      // up arrow at top hides suggestions
      keyDown(38)
      expect(autoSuggest.state().showSuggestions).toEqual(false)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(-1)

      // down arrow shows suggestions
      keyDown(40)
      expect(autoSuggest.state().showSuggestions).toEqual(true)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(0)

      // escape hides suggestions
      keyDown(27)
      expect(autoSuggest.state().showSuggestions).toEqual(false)
      expect(autoSuggest.state().selectedSuggestionIndex).toEqual(-1)

      // enter after showing and selecting second suggestion hides the suggestions and invokes the callback
      onChange.mockClear()
      expect(onChange).not.toBeCalledWith("test")
      keyDown(40)
      keyDown(40)
      keyDown(13)
      expect(autoSuggest.state().showSuggestions).toEqual(false)
      expect(onChange).toBeCalledWith("test 2")
    });

    it("should handle mouse clicks on suggestions", () => {
      const onSubmit = jest.fn()
      const autoSuggest = Enzyme.mount(<AutoSuggest query="test" onSubmit={onSubmit} />);
      const input = autoSuggest.find("input").first()
      const keyDown = (keyCode) => input.prop("onKeyDown")({keyCode, preventDefault: () => undefined, stopPropagation: () => undefined})

      // do the query
      input.prop("onChange")({target: {value: "test"}})
      autoSuggest.update()

      let suggestion = autoSuggest.find(".suggestion").first()
      suggestion.simulate("click")
      expect(onSubmit).toBeCalledWith("test 1")

      // show suggestions again
      keyDown(40)
      autoSuggest.update()

      suggestion = autoSuggest.find(".suggestion").at(1)
      onSubmit.mockClear()
      suggestion.simulate("click")
      expect(onSubmit).toBeCalledWith("test 2")
    });
  })
})
