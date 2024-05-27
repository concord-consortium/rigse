/* globals describe it expect */
import React from 'react';
import Formsy from 'formsy-react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/school_input... Remove this comment to see the full error message
import SchoolInput from 'components/signup/school_input';

describe('When I try to render signup school input', () => {
  it("should render", () => {
    render(
      <Formsy>
        <SchoolInput name="test" />
      </Formsy>
    );

    expect(screen.getByRole('combobox')).toBeInTheDocument();
    expect(screen.getByText('Select...')).toBeInTheDocument();
  });
});
