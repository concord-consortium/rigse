import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/materials-bin/mater... Remove this comment to see the full error message
import MBMaterialsCategory from 'components/materials-bin/materials-category';

describe('When I try to render materials-bin materials category', () => {
  it('should render with default props', () => {
    render(<MBMaterialsCategory><div>children...</div></MBMaterialsCategory>);

    const container = screen.getByText('children...').parentElement;
    expect(container).toHaveClass('mb-cell', 'mb-category', 'mb-clickable', 'mb-hidden');

  });

  it('should render with optional props', () => {
    const handleClick = jest.fn();
    render(
      <MBMaterialsCategory customClass="foo" visible={true} selected={true} handleClick={handleClick}>
        <div>children...</div>
      </MBMaterialsCategory>
    );

    const container = screen.getByText('children...').parentElement;
    expect(container).toHaveClass('mb-cell', 'mb-category', 'mb-clickable', 'foo', 'mb-selected');


    expect(handleClick).not.toHaveBeenCalled();
    // @ts-expect-error TS(2345): Argument of type 'HTMLElement | null' is not assig... Remove this comment to see the full error message
    fireEvent.click(container);
    expect(handleClick).toHaveBeenCalled();
  });
});
