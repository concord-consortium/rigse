/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/forgot_passw... Remove this comment to see the full error message
import ForgotPasswordModal from 'components/signup/forgot_password_modal';

describe('When I try to render signup user type selector', () => {
  it("should render", () => {
    render(<ForgotPasswordModal />);

    // Check for the presence of various elements in the modal
    expect(screen.getByRole('heading', { name: /forgot your login information\?/i })).toBeInTheDocument();
    expect(screen.getByText('Students:')).toBeInTheDocument();
    expect(screen.getByText(/ask your teacher for help\./i)).toBeInTheDocument();
    expect(screen.getByText('Teachers:')).toBeInTheDocument();
    expect(screen.getByText('Enter your username or email address below.')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /submit/i })).toBeInTheDocument();
  });
});
