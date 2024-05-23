import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import MaterialsBin from 'components/materials-bin/materials-bin';
import { mockJqueryAjax } from "../../helpers/mock-jquery"

const materials = [
  {
    category: 'Cat A',
    className: 'custom-category-class',
    children: [
      {
        category: 'Cat A1',
        children: [
          {
            collections: [{ id: 'Collection 2' }],
          },
        ],
      },
      {
        category: 'Cat A2',
        children: [],
      },
    ],
  },
  {
    category: 'Cat B',
    children: [
      {
        category: 'Cat B1',
        children: [
          {
            collections: [{ id: 'Collection 3' }],
          },
        ],
      },
      {
        category: 'Cat B2',
        children: [],
      },
    ],
  },
  {
    category: 'Cat C',
    loginRequired: true,
    children: [
      {
        ownMaterials: true,
      },
    ],
  },
  {
    category: 'Cat D',
    children: [
      {
        materialsByAuthor: true,
      },
    ],
  },
];

global.Portal = {
  API_V1: {
    MATERIALS_OWN: 'https://example.com/',
  },
  currentUser: {
    isTeacher: true,
  },
};

describe('When I try to render materials-bin', () => {
  mockJqueryAjax();

  it('should render with default props', () => {
    render(<MaterialsBin materials={materials} />);

    expect(screen.getByText('Cat A')).toBeInTheDocument();
    expect(screen.getByText('Cat B')).toBeInTheDocument();
    expect(screen.getByText('Cat C')).toBeInTheDocument();
    expect(screen.getByText('Cat D')).toBeInTheDocument();

    const loadingElements = screen.getAllByText('loading');
    expect(loadingElements).toHaveLength(2);

    // Check DOM structure for Cat A and its children
    const catAElement = screen.getByText('Cat A');
    expect(catAElement).toHaveClass('custom-category-class', 'mb-clickable', 'mb-selected');

    const catA1Element = screen.getByText('Cat A1');
    expect(catA1Element).toBeInTheDocument();
    expect(catA1Element).toHaveClass('mb-clickable', 'mb-selected');

    const catA2Element = screen.getByText('Cat A2');
    expect(catA2Element).toBeInTheDocument();
    expect(catA2Element).toHaveClass('mb-clickable');

    // Check DOM structure for Cat B and its children
    const catBElement = screen.getByText('Cat B');
    expect(catBElement).toHaveClass('mb-clickable');

    const catB1Element = screen.getByText('Cat B1');
    expect(catB1Element).toHaveClass('mb-hidden');

    const catB2Element = screen.getByText('Cat B2');
    expect(catB2Element).toHaveClass('mb-hidden');

    // Check DOM structure for Cat C and its children
    const catCElement = screen.getByText('Cat C');
    expect(catCElement).toHaveClass('mb-clickable');

    // Check DOM structure for Cat D and its children
    const catDElement = screen.getByText('Cat D');
    expect(catDElement).toHaveClass('mb-clickable');
  });

  it('should handle clicking of categories', async () => {
    render(<MaterialsBin materials={materials} />);

    const categoryB = screen.getByText('Cat B');
    fireEvent.click(categoryB);

    await waitFor(() => {
      const selectedCategoryB = screen.getByText('Cat B');
      expect(selectedCategoryB).toHaveClass('mb-selected');

      const categoryA = screen.getByText('Cat A');
      const categoryC = screen.getByText('Cat C');
      const categoryD = screen.getByText('Cat D');

      expect(categoryA).not.toHaveClass('mb-selected');
      expect(categoryC).not.toHaveClass('mb-selected');
      expect(categoryD).not.toHaveClass('mb-selected');

      // Check DOM structure after clicking Cat B
      const catB1Element = screen.getByText('Cat B1');
      expect(catB1Element).toHaveClass('mb-clickable');
      expect(catB1Element).not.toHaveClass('mb-hidden');

      const catB2Element = screen.getByText('Cat B2');
      expect(catB2Element).toHaveClass('mb-clickable');
      expect(catB2Element).not.toHaveClass('mb-hidden');

      const hiddenCategories = screen.getAllByText('Loading...');
      expect(hiddenCategories).toHaveLength(2);
    });
  });
});
