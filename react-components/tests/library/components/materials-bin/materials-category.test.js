import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
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
    fireEvent.click(container);
    expect(handleClick).toHaveBeenCalled();
  });
});
