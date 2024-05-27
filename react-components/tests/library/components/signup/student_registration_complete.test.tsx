/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/student_regi... Remove this comment to see the full error message
import StudentRegistrationComplete from 'components/signup/student_registration_complete';

// @ts-expect-error TS(2304): Cannot find name 'global'.
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
