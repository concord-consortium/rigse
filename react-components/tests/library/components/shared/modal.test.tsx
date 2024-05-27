/* globals describe it expect */

import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/shared/modal' or it... Remove this comment to see the full error message
import Modal from 'components/shared/modal';

describe('When I try to render a modal', () => {

  it("should render without children", () => {
    render(<Modal />);

    const modal = screen.getByRole('dialog');
    expect(modal).toBeInTheDocument();

    const background = screen.getByTestId('modal-background');
    expect(background).toBeInTheDocument();
  });

  it("should render with children", () => {
    render(<Modal><div>children here...</div></Modal>);

    const modal = screen.getByRole('dialog');
    expect(modal).toBeInTheDocument();

    const background = screen.getByTestId('modal-background');
    expect(background).toBeInTheDocument();

    const childrenContent = screen.getByText('children here...');
    expect(childrenContent).toBeInTheDocument();
  });

});
