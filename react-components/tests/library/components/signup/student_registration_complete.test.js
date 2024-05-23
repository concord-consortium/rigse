/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
import StudentRegistrationComplete from 'components/signup/student_registration_complete';

global.ga = jest.fn();

describe('When I try to render signup student registration complete', () => {

  it("should render as anonymous", () => {
    render(<StudentRegistrationComplete anonymous={true} data={{ login: "data-login" }} />);

    expect(screen.getByText('Success! Your username is')).toBeInTheDocument();
    expect(screen.getByText('data-login')).toBeInTheDocument();
    expect(screen.getByText('Use your new account to sign in below.')).toBeInTheDocument();
    expect(screen.getByText('Username')).toBeInTheDocument();
    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Log In!' })).toBeInTheDocument();
  });

});
