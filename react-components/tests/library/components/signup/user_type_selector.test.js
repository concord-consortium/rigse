/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
import UserTypeSelector from 'components/signup/user_type_selector'

describe('When I try to render signup user type selector', () => {

  it("should render", () => {
    render(<UserTypeSelector />);

    // Check if the teacher button is rendered
    expect(screen.getByRole('button', { name: /I am a Teacher/i })).toBeInTheDocument();
    // Check if the student button is rendered
    expect(screen.getByRole('button', { name: /I am a Student/i })).toBeInTheDocument();
    // Check if the login option paragraph is rendered
    expect(screen.getByText("Already have an account?")).toBeInTheDocument();
    // Check if the login link is rendered
    expect(screen.getByRole('link', { name: /Log in »/i })).toBeInTheDocument();
  });

})
