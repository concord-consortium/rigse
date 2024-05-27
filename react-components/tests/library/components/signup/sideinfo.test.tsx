/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/signup/sideinfo' or... Remove this comment to see the full error message
import SideInfo from 'components/signup/sideinfo';

describe('When I try to render signup side info', () => {
  it("should render", () => {
    render(<SideInfo />);

    expect(screen.getByText('Why sign up?')).toBeInTheDocument();
    expect(screen.getByText("It's free and you get access to several key features:")).toBeInTheDocument();
    expect(screen.getByText('Create classes for your students and assign them activities')).toBeInTheDocument();
    expect(screen.getByText('Save student work')).toBeInTheDocument();
    expect(screen.getByText('Track student progress through activities')).toBeInTheDocument();
  });
});
