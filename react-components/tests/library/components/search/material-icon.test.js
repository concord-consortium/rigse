import React from 'react';
import { render, screen } from '@testing-library/react';
import SMaterialIcon from 'components/search/material-icon';

describe('When I try to render search material icon', () => {

  it("should render with default props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {}
    }
    const configuration = {};
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole('img');
    expect(image).toHaveAttribute('src', 'http://example.com/icon');
    expect(image).toHaveAttribute('width', '100%');
  });

  it("should render with unstarred favorites props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      }
    }
    const configuration = {
      enableFavorites: true,
      favoriteClassMap: {
        true: "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole('img');
    expect(image).toHaveAttribute('src', 'http://example.com/icon');
    expect(image).toHaveAttribute('width', '100%');

    const thumbLink = screen.getByRole('link');
    expect(thumbLink).toHaveAttribute('href', 'http://example.com/browse');

    const favorite = screen.getByText('★');
    const favoriteOutline = screen.getByText('☆');
    expect(favorite).toHaveClass('legacy-favorite');
    expect(favoriteOutline).toHaveClass('legacy-favorite legacy-favorite-outline');
  });

  it("should render with starred favorites props", () => {
    const material = {
      icon: {
        url: "http://example.com/icon"
      },
      links: {
        browse: {
          url: "http://example.com/browse"
        }
      },
      is_favorite: true
    }
    const configuration = {
      enableFavorites: true,
      favoriteClassMap: {
        true: "legacy-favorite-active",
        false: "legacy-favorite"
      },
      favoriteOutlineClass: "legacy-favorite-outline",
      width: 100,
      height: 200
    };
    render(<SMaterialIcon material={material} configuration={configuration} />);

    const image = screen.getByRole('img');
    expect(image).toHaveAttribute('src', 'http://example.com/icon');
    expect(image).toHaveAttribute('width', '100%');

    const thumbLink = screen.getByRole('link');
    expect(thumbLink).toHaveAttribute('href', 'http://example.com/browse');

    const favorite = screen.getByText('★');
    expect(favorite).toHaveClass('legacy-favorite legacy-favorite-active');
  });

});
