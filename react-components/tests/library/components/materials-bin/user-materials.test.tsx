import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/materials-bin/user-... Remove this comment to see the full error message
import MBUserMaterials from 'components/materials-bin/user-materials';
import { mockJqueryAjaxSuccess } from '../../helpers/mock-jquery';

const materials = [
  {
    id: 1,
    name: 'material 1',
    icon: {
      url: 'http://example.com/icon',
    },
    links: {},
    material_properties: '',
    activities: [],
  },
  {
    id: 2,
    name: 'material 2',
    icon: {
      url: 'http://example.com/icon',
    },
    links: {},
    material_properties: '',
    activities: [],
  },
];

// @ts-expect-error TS(2304): Cannot find name 'global'.
global.Portal = {
  API_V1: {
    MATERIALS_BIN_UNOFFICIAL_MATERIALS: 'http://example.com',
  },
  currentUser: {
    isTeacher: false,
  },
};

describe('When I try to render materials-bin user materials', () => {
  mockJqueryAjaxSuccess(materials);

  it('should render with default props', () => {
    render(<MBUserMaterials userId={1} />);

    expect(screen.getByText('+')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    const hiddenContainer = screen.getByText('Loading...').parentElement;
    expect(hiddenContainer).toHaveClass('mb-hidden');
  });

  it('should render with optional props', () => {
    render(<MBUserMaterials userId={1} name="Collection Name" />);

    expect(screen.getByText('Collection Name')).toBeInTheDocument();
    expect(screen.getByText('+')).toBeInTheDocument();
    expect(screen.getByText('Loading...')).toBeInTheDocument();
    const hiddenContainer = screen.getByText('Loading...').parentElement;
    expect(hiddenContainer).toHaveClass('mb-hidden');
  });

  it('should allow toggling which loads data', async () => {
    render(<MBUserMaterials userId={1} name="Collection Name" />);

    const toggleButton = screen.getByText('Collection Name').closest('.mb-collection-name');
    // @ts-expect-error TS(2345): Argument of type 'Element | null' is not assignabl... Remove this comment to see the full error message
    fireEvent.click(toggleButton);

    await waitFor(() => {
      const collectionHeader = screen.getByRole('heading', { level: 3 });
      expect(collectionHeader).toHaveClass('mb-collection-name');
      expect(collectionHeader).toHaveTextContent('');
    });

    const materialsElements = screen.getAllByRole('heading', { level: 4 });
    expect(materialsElements).toHaveLength(2);

    expect(materialsElements[0]).toHaveTextContent('material 1');
    expect(materialsElements[1]).toHaveTextContent('material 2');

    const images = screen.getAllByRole('img');
    expect(images).toHaveLength(2);
    expect(images[0]).toHaveAttribute('src', 'http://example.com/icon');
    expect(images[0]).toHaveAttribute('alt', 'material 1');
    expect(images[1]).toHaveAttribute('src', 'http://example.com/icon');
    expect(images[1]).toHaveAttribute('alt', 'material 2');
  });

  // TODO: add test for archiveSingle()
});
