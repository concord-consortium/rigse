/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
import Formsy from 'formsy-react';
import RadioInput from 'components/signup/radio_input';

describe('When I try to render signup radio buttons', () => {
  it("should render", () => {
    const options = [
      { label: "Option 1", value: 1 },
      { label: "Option 2", value: 2 }
    ];

    render(
      <Formsy>
        <RadioInput name="test" title="test" options={options} />
      </Formsy>
    );

    expect(screen.getByText('test')).toBeInTheDocument();
    expect(screen.getByLabelText('Option 1')).toBeInTheDocument();
    expect(screen.getByLabelText('Option 2')).toBeInTheDocument();
    expect(screen.getByLabelText('Option 1')).toHaveAttribute('type', 'radio');
    expect(screen.getByLabelText('Option 2')).toHaveAttribute('type', 'radio');
  });
});
