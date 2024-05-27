import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/materials-bin/mater... Remove this comment to see the full error message
import MBMaterial from 'components/materials-bin/material';

const material = {
  id: 1,
  name: 'material 1',
  icon: {
    url: 'http://example.com/icon',
  },
  links: {},
  material_properties: '',
  activities: [],
};

// @ts-expect-error TS(2304): Cannot find name 'global'.
global.Portal = {
  currentUser: {
    isTeacher: true,
  },
};

describe('When I try to render materials-bin material', () => {
  it('should render with default props', () => {
    render(<MBMaterial material={material} />);

    const materialName = screen.getByText('material 1');
    const materialImage = screen.getByAltText('material 1');

    expect(materialName).toBeInTheDocument();
    expect(materialImage).toBeInTheDocument();
    expect(materialImage).toHaveAttribute('src', 'http://example.com/icon');
  });
});
