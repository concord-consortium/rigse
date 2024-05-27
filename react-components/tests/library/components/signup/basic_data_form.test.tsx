/* globals describe it expect */

import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/basic_data_f... Remove this comment to see the full error message
import BasicDataForm from 'components/signup/basic_data_form';

describe('When I try to render signup basic data form', () => {

  it("should render with default props", () => {
    render(<BasicDataForm />);

    const form = screen.getByRole('form');
    expect(form).toBeInTheDocument();

    const thirdPartyLoginOptions = screen.getByTestId('third-party-login-options');
    expect(thirdPartyLoginOptions).toBeInTheDocument();

    // @ts-expect-error TS(2769): No overload matches this call.
    const submitButton = screen.getByRole('button', { type: 'submit' });
    expect(submitButton).toBeInTheDocument();
  });

  it("should render with anonymous prop", () => {
    render(<BasicDataForm anonymous={true} />);

    const form = screen.getByRole('form');
    expect(form).toBeInTheDocument();

    const thirdPartyLoginOptions = screen.getByTestId('third-party-login-options');
    expect(thirdPartyLoginOptions).toBeInTheDocument();

    expect(screen.getByText('First Name')).toBeInTheDocument();
    expect(screen.getByText('Last Name')).toBeInTheDocument();
    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByText('Confirm Password')).toBeInTheDocument();

    // @ts-expect-error TS(2769): No overload matches this call.
    const submitButton = screen.getByRole('button', { type: 'submit' });
    expect(submitButton).toBeInTheDocument();
    expect(submitButton).toBeDisabled();
  });

});
