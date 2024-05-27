/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
import Formsy from 'formsy-react'
// @ts-expect-error TS(2307): Cannot find module 'components/signup/text_input' ... Remove this comment to see the full error message
import TextInput from 'components/signup/text_input'

describe('When I try to render signup text input', () => {

  it("should render", () => {
    render(
      <Formsy>
        <TextInput name="test" />
      </Formsy>
    );

    // Check if the input is rendered
    expect(screen.getByRole('textbox')).toBeInTheDocument();
    // Check if the input has the correct name attribute
    expect(screen.getByRole('textbox')).toHaveAttribute('name', 'test');
  });

})
