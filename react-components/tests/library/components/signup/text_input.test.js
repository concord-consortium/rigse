/* globals describe it expect */
import React from 'react'
import Formsy from 'formsy-react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import TextInput from 'components/signup/text_input'
import { pack } from "../../helpers/pack"

Enzyme.configure({adapter: new Adapter()})

describe('When I try to render signup text input', () => {

  it("should render", () => {
    const radioInput = Enzyme.mount(<Formsy><TextInput name="test" /></Formsy>);
    expect(radioInput.html()).toBe(pack(`
      <form>
        <div class="text-input test">
          <input type="text" value="">
          <div class="input-error"></div>
        </div>
      </form>
    `));
  });

})