import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/materials-bin/mater... Remove this comment to see the full error message
import MBMaterialsCollection from 'components/materials-bin/materials-collection';

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
  currentUser: {
    isTeacher: true,
  },
};

describe('When I try to render materials-bin materials collection', () => {
  it('should render with default props', () => {
    render(<MBMaterialsCollection materials={materials} />);

    const collectionHeader = screen.getByRole('heading', { level: 3 });
    expect(collectionHeader).toBeInTheDocument();
    expect(collectionHeader).toHaveClass('mb-collection-name');
    expect(collectionHeader).toHaveTextContent('');

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

  it('should render with optional props', () => {
    render(
      <MBMaterialsCollection
        materials={materials}
        name="Collection"
        teacherGuideUrl="http://example.com/"
      />
    );

    const collectionHeader = screen.getByRole('heading', { level: 3 });
    expect(collectionHeader).toBeInTheDocument();
    expect(collectionHeader).toHaveClass('mb-collection-name');
    expect(collectionHeader).toHaveTextContent('Collection');

    const teacherGuideLink = screen.getByRole('link', { name: 'Teacher Guide' });
    expect(teacherGuideLink).toBeInTheDocument();
    expect(teacherGuideLink).toHaveAttribute('href', 'http://example.com/');
    expect(teacherGuideLink).toHaveAttribute('target', '_blank');

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
});
