/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/login_modal'... Remove this comment to see the full error message
import LoginModal from 'components/signup/login_modal';

describe('When I try to render signup user type selector', () => {
  it("should render", () => {
    render(<LoginModal />);

    // Check for the presence of various elements in the modal
    expect(screen.getByRole('heading', { name: "Log in to the Portal" })).toBeInTheDocument();
    expect(screen.getByText("Sign in with:")).toBeInTheDocument();
    expect(screen.getByText("Or")).toBeInTheDocument();
    expect(screen.getByText("Username")).toBeInTheDocument();
    expect(screen.getByText("Password")).toBeInTheDocument();
    expect(screen.getByRole('link', { name: "Forgot your username or password?" })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: "Log In!" })).toBeInTheDocument();
  });
});
