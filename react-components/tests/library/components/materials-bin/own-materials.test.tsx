import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/materials-bin/own-m... Remove this comment to see the full error message
import MBOwnMaterials from 'components/materials-bin/own-materials';
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

describe('When I try to render materials-bin own materials', () => {
  mockJqueryAjaxSuccess(materials);

  it('should render with default props', () => {
    render(<MBOwnMaterials userId={1} />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should render with optional props', async () => {
    render(<MBOwnMaterials userId={1} name="Collection Name" visible={true} />);

    await waitFor(() => {
      const collectionHeader = screen.getByRole('heading', { level: 3 });
      expect(collectionHeader).toHaveTextContent('My activities');
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
