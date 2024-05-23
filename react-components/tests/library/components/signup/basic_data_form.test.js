/* globals describe it expect */

import React from 'react';
import { render, screen } from '@testing-library/react';
import BasicDataForm from 'components/signup/basic_data_form';

describe('When I try to render signup basic data form', () => {

  it("should render with default props", () => {
    render(<BasicDataForm />);

    const form = screen.getByRole('form');
    expect(form).toBeInTheDocument();

    const thirdPartyLoginOptions = screen.getByTestId('third-party-login-options');
    expect(thirdPartyLoginOptions).toBeInTheDocument();

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

    const submitButton = screen.getByRole('button', { type: 'submit' });
    expect(submitButton).toBeInTheDocument();
    expect(submitButton).toBeDisabled();
  });

});
