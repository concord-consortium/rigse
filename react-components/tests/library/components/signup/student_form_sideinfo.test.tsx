/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/student_form... Remove this comment to see the full error message
import StudentFormSideInfo from 'components/signup/student_form_sideinfo';

describe('When I try to render signup student form sideinfo', () => {
  it('should render', () => {
    render(<StudentFormSideInfo />);
    expect(screen.getByText("Enter the class word your teacher gave you. If you don't know what the class word is, ask your teacher.")).toBeInTheDocument();
  });
});
