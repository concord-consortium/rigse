/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/student_regi... Remove this comment to see the full error message
import StudentRegistrationCompleteSideInfo from 'components/signup/student_registration_complete_sideinfo';
import {mockJquery} from "../../helpers/mock-jquery"

const mockedJQuery = () => ({
  each: () => {},
  attr: () => ""
});

describe('When I try to render signup student registration complete sideinfo', () => {

  mockJquery(mockedJQuery)

  it('should render', () => {
    render(<StudentRegistrationCompleteSideInfo />);
    expect(screen.getByText('Sign In')).toBeInTheDocument();
    expect(screen.getByText('Username')).toBeInTheDocument();
    expect(screen.getByText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Log In' })).toBeInTheDocument();
  });
});
