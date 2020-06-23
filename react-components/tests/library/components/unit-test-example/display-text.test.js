import React from 'react'
import Enzyme from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import DisplayText from 'components/unit-test-example/display-text'

Enzyme.configure( { adapter: new Adapter() });

describe('When I try to display some text', () => {
  const label = "this is a label";
  const value = "this is a value";
  const display_text = Enzyme.mount(<DisplayText label={label} value={value} />);
  it ('shows what I asked for in the label', () => {
    expect(display_text.prop('value')).toBe(value);
  });
  it ('shows what I asked for as the value', () => {
    expect(display_text.prop('label')).toBe(label)
  });
});