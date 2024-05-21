import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import MBMaterialsByAuthor from 'components/materials-bin/materials-by-author';
import { mockJqueryAjaxSuccess } from '../../helpers/mock-jquery';

const authors = [
  {
    id: 1,
    name: 'author 1',
    materials: [
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
    ],
  },
  {
    id: 2,
    name: 'author 2',
  },
];

global.Portal = {
  API_V1: {
    MATERIALS_BIN_UNOFFICIAL_MATERIALS: 'http://example.com',
  },
  currentUser: {
    isTeacher: false,
  },
};

describe('When I try to render materials-bin materials by author', () => {
  mockJqueryAjaxSuccess(authors);

  it('should render with default props', () => {
    render(<MBMaterialsByAuthor userId={1} />);

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });

  it('should render with optional props', async () => {
    render(<MBMaterialsByAuthor userId={1} name="Collection Name" visible={true} />);

    await waitFor(() => {
      expect(screen.getByText('author 1')).toBeInTheDocument();
      expect(screen.getByText('author 2')).toBeInTheDocument();
    });

    const loadingElements = screen.getAllByText('Loading...');
    expect(loadingElements).toHaveLength(2);
  });
});
