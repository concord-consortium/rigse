import React from 'react';
import { render, screen } from '@testing-library/react';
// @ts-expect-error TS(2307): Cannot find module 'components/search/material-hea... Remove this comment to see the full error message
import SMaterialHeader from 'components/search/material-header';

describe('When I try to render search material header', () => {

  it("should render with default props", () => {
    const material = {
      material_properties: "",
      publication_status: "published",
      links: {}
    }
    render(<SMaterialHeader material={material} />);

    expect(screen.getByText('Runs in browser')).toBeInTheDocument();
    expect(screen.getByText('Community')).toBeInTheDocument();
  });

  it("should render with optional props", () => {
    const material = {
      name: "material name",
      material_properties: "Requires download",
      is_official: true,
      publication_status: "draft",
      links: {
        browse: {
          url: "http://example.com/browse"
        },
        edit: {
          url: "http://example.com/edit",
          text: "edit text"
        },
        external_edit_iframe: {
          url: "http://example.com/external_edit_iframe",
          text: "external_edit_iframe text"
        }
      }
    }
    render(<SMaterialHeader material={material} />);

    expect(screen.getByText('Requires download')).toBeInTheDocument();
    expect(screen.getByText('Official')).toBeInTheDocument();
    expect(screen.getByText('draft')).toBeInTheDocument();
    expect(screen.getByText('material name')).toBeInTheDocument();
    expect(screen.getByText('edit text')).toBeInTheDocument();
    expect(screen.getByText('external_edit_iframe text')).toBeInTheDocument();
  });

});
