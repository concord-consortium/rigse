/* globals describe it expect */
import React from 'react'
import { render, screen } from '@testing-library/react'
// @ts-expect-error TS(2307): Cannot find module 'components/signup/teacher_regi... Remove this comment to see the full error message
import TeacherRegistrationComplete from 'components/signup/teacher_registration_complete'

// @ts-expect-error TS(2339): Property 'gtag' does not exist on type 'Window & t... Remove this comment to see the full error message
window.gtag = jest.fn()

describe('When I try to render signup teacher registration complete', () => {

  it("should render with default props", () => {
    render(<TeacherRegistrationComplete />);

    expect(screen.getByText('Thanks for signing up!')).toBeInTheDocument();
    expect(screen.getByText('Start using the site.')).toBeInTheDocument();
  });

  it("should render with anonymous prop", () => {
    render(<TeacherRegistrationComplete anonymous={true} />);

    expect(screen.getByText('Thanks for signing up!')).toBeInTheDocument();
    expect(screen.getByText("We're sending you an email with your activation code. Click the \"Confirm Account\" link in the email to complete the process.")).toBeInTheDocument();
  });

});
