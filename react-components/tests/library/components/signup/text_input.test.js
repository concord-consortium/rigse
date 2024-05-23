/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
import Formsy from 'formsy-react'
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
