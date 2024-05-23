/* globals describe it expect */
import React from 'react';
import { render, screen } from '@testing-library/react';
import SearchResultGroup from 'components/search/result-group';
import { mockJquery } from "../../helpers/mock-jquery"

describe('When I try to render search result group', () => {
  mockJquery(() => ({
    paging: jest.fn()
  }));

  it('should render with default props', () => {
    const group = {
      type: 'investigations',
      pagination: {
        total_items: 10,
        per_page: 20,
        start_item: 1,
        end_item: 20,
      },
      materials: [],
    };

    render(<SearchResultGroup group={group} />);

    const container = screen.getByTestId('materials-container');
    expect(container).toHaveClass('materials_container', 'investigations');

    expect(screen.getByTestId('material-list-header')).toBeInTheDocument();

    expect(screen.getByText('Displaying')).toBeInTheDocument();
    expect(screen.getByText('all 10')).toBeInTheDocument();
  });
});
