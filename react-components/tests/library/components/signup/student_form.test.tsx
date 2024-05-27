/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/student_form... Remove this comment to see the full error message
import StudentForm from 'components/signup/student_form';

// @ts-expect-error TS(2304): Cannot find name 'global'.
global.Portal = {
  API_V1: {
    CLASSWORD: "http://example.com/classword",
    STUDENTS: "http://example.com/students",
  }
};

describe('When I try to render signup student form', () => {
  it('should render', () => {
    render(<StudentForm />);
    expect(screen.getByText('Class Word')).toBeInTheDocument();
    expect(screen.getByPlaceholderText('Class Word (not case sensitive)')).toBeInTheDocument();
    expect(screen.getByText('By clicking Register!, you agree to our', { exact: false })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Register!' })).toBeInTheDocument();
  });
});
