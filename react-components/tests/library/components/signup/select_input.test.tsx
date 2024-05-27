/* globals describe it expect */
import React from 'react';
import Formsy from 'formsy-react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/select_input... Remove this comment to see the full error message
import SelectInput from 'components/signup/select_input';

describe('When I try to render signup select input', () => {
  it("should render", () => {
    const loadOptions = () => [
      { label: "Option 1", value: 1 },
      { label: "Option 2", value: 2 }
    ];

    render(
      <Formsy>
        <SelectInput name="test" placeholder="placeholder" loadOptions={loadOptions} />
      </Formsy>
    );

    expect(screen.getByRole('combobox')).toBeInTheDocument();
    expect(screen.getByText('placeholder')).toBeInTheDocument();
  });
});
