/* globals describe it expect */
import React from 'react'
import Formsy from 'formsy-react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import RadioInput from 'components/signup/radio_input'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup radio buttons', () => {

  it("should render", () => {
    const options = [
      {label: "Option 1", value: 1},
      {label: "Option 2", value: 2}
    ]
    const radioInput = Enzyme.mount(<Formsy><RadioInput name="test" title="test" options={options} /></Formsy>);
    expect(radioInput.html()).toBe(pack(`
      <form>
        <div class="radio-input stacked">
          <div class="title inline">test</div>
          <label>
            <input type="radio" name="test" value="1"> Option 1
          </label>
          <label>
            <input type="radio" name="test" value="2"> Option 2
          </label>
        </div>
      </form>
    `));
  });

})